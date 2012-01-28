require 'rubygems'
require 'net/http'
require 'json'
require 'open-uri'
require './lib/build_status'

class Jenkins
  API_SUFFIX = '/api/json?token=TOKEN'
  CLAIM_ACTION_INDEX = 6

  def initialize(config)
    @url = config['jenkins_url']
    @username = config['username']
    @api_token = config['api_token']
  end

  def job_list
    jobs = api_request(@url)['jobs']
    jobs.collect { |job| job['name'] }
  end

  def job_statuses
    job_statuses = {}
    job_list.each do |job_name|
      build_number = last_build_number(job_name)
      job_statuses[job_name] = build_status(job_name, build_number)
    end
    job_statuses
  end

  def job_details(job_name)
    api_request("#{@url}/job/#{URI::encode(job_name)}")
  end

  def last_build_number(job_name)
    job_details(job_name)['lastCompletedBuild']['number']
  end

  def build_details(job_name, build_number)
    api_request("#{@url}/job/#{URI::encode(job_name)}/#{build_number}")
  end

  def build_status(job_name, build_number)
    build_details_json = build_details(job_name, build_number)
    BuildStatus.new(build_result(build_details_json), build_claimed?(build_details_json))
  end

  def failed_builds
    job_statuses.delete_if {|job_name, build_status| !build_status.failure? }
  end

  def has_no_build_failures?
    failed_builds.empty?
  end

  def has_build_failure?
    !has_no_build_failures?
  end

  def unclaimed_builds
    failed_builds.delete_if {|job_name, build_status| build_status.claimed? }
  end

  def has_unclaimed_build?
    !has_no_unclaimed_builds?
  end

  def has_no_unclaimed_builds?
    unclaimed_builds.empty?
  end

  private

  def build_result(build_details_json)
    build_details_json['result']
  end

  def build_claimed?(build_details_json)
    claim_details = build_details_json['actions'][CLAIM_ACTION_INDEX]
    claimed = claim_details['claimed'] if claim_details
    claimed = false if claimed.nil?
    claimed
  end

  def api_request(url)
    api_url = "#{url}/#{API_SUFFIX}"
    uri = URI(api_url)

    req = Net::HTTP::Get.new(uri.request_uri)
    req.basic_auth @username, @api_token if @username && @api_token

    res = Net::HTTP.start(uri.host, uri.port) do |http|
      http.request(req)
    end

    JSON.parse(res.body)
  end

end
