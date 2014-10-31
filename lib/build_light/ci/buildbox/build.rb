require 'rubygems'
require 'net/http'
require 'json'
require 'open-uri'

module CI

  module Buildbox

    class Build

      include ::Logger

      attr_reader :build_data, :jobs, :name

      def initialize(build_name:, config:)
        @name = build_name
        @url = config[:url]
        @api_suffix = "accounts/#{config[:organisation]}/projects/#{name}/builds?api_key=#{config[:api_token]}"
        @build_data = fetch_build
        logger.info "Latest fully completed build for project '#{name}' is ##{build_data['number']}"
      end

      def success?
        failed_jobs.empty?
      end

      def failure?
        !success?
      end

      def jobs
        @jobs ||= assemble_jobs
      end

      def successful_jobs
        jobs.select { |job| job.success? }
      end

      def failed_jobs
        jobs.select { |job| job.failure? and job.enabled? }
      end

      def unclaimed_jobs
        jobs.delete_if {|job| job.claimed? }
      end

      def has_unclaimed_jobs?
        !has_no_unclaimed_jobs?
      end

      def has_no_unclaimed_jobs?
        unclaimed_jobs.empty?
      end

      def culprits
        jobs.map {|job| job.culprits }.flatten.uniq
      end

      private

      attr_reader :url, :api_suffix

      def job job_data
        Job.new job_data
      end

      def assemble_jobs
        logger.info "Assembling jobs for #{name}"
        job_list = []
        valid_jobs.each do |job_data|
          job_list.push(job job_data)
        end
        job_list
      end

      def valid_jobs
        build_data['jobs'].reject{ |job| ['waiter', 'manual'].include? job['type'] }
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