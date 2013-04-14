require 'rubygems'
require 'net/http'
require 'json'
require 'open-uri'

class Jenkins
  API_SUFFIX = '/api/json?token=TOKEN&depth=2&tree=jobs[name,lastCompletedBuild[result,timestamp,duration,actions[claimed],culprits[fullName]]]'

  def initialize(config)
    @url = config['jenkins_url']
    @username = config['username']
    @api_token = config['api_token']
  end

  def jobs
    @jobs ||= api_request(@url)['jobs']
  end

  def job_statuses
    job_statuses = {}
    jobs.each do |job|
      job_statuses[job['name']] = build_status(job)
    end
    job_statuses
  end

  def build_status(job)
    BuildStatus.new(job)
  end

  def successful_builds
    job_statuses.select {|job_name, build_status| build_status.success? }
  end

  def failed_builds
    job_statuses.select {|job_name, build_status| build_status.failure? }
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

  def api_request(url)
    # api_url = "#{url}/#{API_SUFFIX}"
    # uri = URI(api_url)

    # req = Net::HTTP::Get.new(uri.request_uri)
    # req.basic_auth @username, @api_token if @username && @api_token

    # res = Net::HTTP.start(uri.host, uri.port) do |http|
    #   http.request(req)
    # end

    # JSON.parse(res.body)
    JSON.parse(File.open('/Users/daniel/Desktop/jenkins2.json', 'r').readlines.first)
  end

end
