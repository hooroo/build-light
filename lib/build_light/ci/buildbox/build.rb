require 'rubygems'
require 'net/http'
require 'json'
require 'open-uri'

module CI

  module Buildbox

    class Build

      include ::Logger

      attr_reader :build

      def initialize(config)
        @url = config[:url]
        @api_suffix = "accounts/#{config[:organisation]}/projects/#{config[:build]}/builds?api_key=#{config[:api_token]}"
        @build = fetch_build
        logger.info "Latest fully completed build is ##{build['number']}"
      end

      def jobs
        @jobs ||= filter_jobs(build['jobs'])
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
        job_statuses.select { |job_name, build_status| build_status.success? }
      end

      def failed_jobs
          job_statuses.select { |job_name, build_status| build_status.failure? and build_status.enabled? }
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

      attr_reader :url, :api_suffix

      def filter_jobs jobs
        jobs.reject{ |job| job['type'] == 'waiter' }
      end

      def fetch_build
        api_request.sort_by { | b | Time.parse(b["created_at"]) }.reverse.detect{ | build | build['finished_at'] && build['state'] != 'canceled' }
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