require 'rubygems'
require 'net/http'
require 'json'
require 'open-uri'

module CI

  class Buildbox


    API_SUFFIX = "/accounts/hooroo/projects/hotels/builds?api_key=#{config[:api_token]}"

    def initialize(config)
      @url = config[:url]
      @username = config[:username]
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
        job_statuses.select {|job_name, build_status| build_status.failure? and build_status.enabled? }
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
      api_url = "#{url}/#{API_SUFFIX}"
      uri = URI(api_url)

      req = Net::HTTP::Get.new(uri.request_uri)

      res = Net::HTTP.start(uri.host, uri.port) do |http|
        http.request(req)
      end

      JSON.parse(res.body)
      # JSON.parse(File.open('/Users/daniel/Desktop/jenkins3.json', 'r').readlines.first)
    end

  end

end