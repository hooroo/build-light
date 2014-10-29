require 'rubygems'
require 'net/http'
require 'json'
require 'open-uri'

module CI

  module Buildbox

    class Build

      def initialize(config)
        @url = config[:url]
        @api_suffix = "accounts/#{config[:organisation]}/projects/#{config[:build]}/builds?api_key=#{config[:api_token]}"
      end

      def jobs
        @jobs ||= filter_jobs(api_request.first['jobs'])
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

      def successful_builds
        job_statuses.select { |job_name, build_status| build_status.success? }
      end

      def failed_builds
          job_statuses.select { |job_name, build_status| build_status.failure? and build_status.enabled? }
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

      attr_reader :url, :api_suffix

      def filter_jobs jobs
        jobs.reject{ |job| job['type'] == 'waiter' }
      end

      def api_request
        api_url = "#{url}/#{api_suffix}"
        uri = URI(api_url)

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        req = Net::HTTP::Get.new(uri.request_uri)

        res = http.request(req)

        JSON.parse(res.body)
        # JSON.parse(File.open('/Users/daniel/Desktop/jenkins3.json', 'r').readlines.first)
      end

    end

  end

end