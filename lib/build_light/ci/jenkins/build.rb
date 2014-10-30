require 'rubygems'
require 'net/http'
require 'json'
require 'open-uri'

module CI

  module Jenkins

    class Build

      API_SUFFIX = '/api/json?token=TOKEN&depth=2&tree=jobs[name,buildable,lastCompletedBuild[result,timestamp,duration,actions[claimed],culprits[fullName]]]'

      def initialize(config)
        @url = config[:url]
        @username = config[:username]
        @api_token = config[:api_token]
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
        Job.new(job)
      end

      def successful_jobs
        job_statuses.select {|job_name, build_status| build_status.success? }
      end

      def failed_jobs
          job_statuses.select {|job_name, build_status| build_status.failure? and build_status.enabled? }
      end

      def has_no_job_failures?
        failed_jobs.empty?
      end

      def has_job_failures?
        !has_no_job_failures?
      end

      def unclaimed_jobs
        failed_jobs.delete_if {|job_name, build_status| build_status.claimed? }
      end

      def has_unclaimed_jobs?
        !has_no_unclaimed_jobs?
      end

      def has_no_unclaimed_jobs?
        unclaimed_jobs.empty?
      end

      private

      def api_request(url)
        api_url = "#{url}/#{API_SUFFIX}"
        uri = URI(api_url)

        req = Net::HTTP::Get.new(uri.request_uri)
        req.basic_auth @username, @api_token if @username && @api_token

        res = Net::HTTP.start(uri.host, uri.port) do |http|
          http.request(req)
        end

        JSON.parse(res.body)
        # JSON.parse(File.open('/Users/daniel/Desktop/jenkins3.json', 'r').readlines.first)
      end

    end

  end

end