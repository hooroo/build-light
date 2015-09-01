require 'net/http'
require 'json'
require 'open-uri'

module CI

  module Buildkite

    class Build

      include ::Logger

      attr_reader :jobs, :name, :organisation, :branch

      URL = 'https://api.buildkite.com/v1'

      def initialize(build_name:, config:)
        @name           = build_name
        @organisation   = config[:organisation]
        @branch         = config[:branch] || 'master'
        @api_suffix     = "organizations/#{organisation}/projects/#{name}/builds?access_token=#{config[:api_token]}&branch=#{branch}"
        logger.info "Latest build for project '#{name}' is ##{build['number']}"
        logger.info "Build '#{name}' building?: #{running?}"
      end

      def build
        @build ||= fetch_build
      end

      def culprits
        @culprits ||= Culprit.new(self).to_a
      end

      def success?
        failed_jobs.empty?
      end

      def failure?
        !success?
      end

      def running?
        running_jobs.any?
      end

      def jobs
        @jobs ||= assemble_jobs
      end

      def successful_jobs
        jobs.select { |job| job.success? }
      end

      def failed_jobs
        jobs.select { |job| job.failure? && job.enabled? }
      end

      def running_jobs
        jobs.select { |job| job.running? }
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

      private

      attr_reader :api_suffix

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
        build['jobs'].reject{ |job| ['waiter', 'manual'].include? job['type'] }
      end

      def fetch_build
        api_request.sort_by { | b | Time.parse(b["created_at"]) }.reverse.first
      end

      def api_request
        api_url = "#{URL}/#{api_suffix}"
        uri = URI(api_url)

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        req = Net::HTTP::Get.new(uri.request_uri)

        res = http.request(req)
        JSON.parse(res.body)

      rescue SocketError
        raise BuildLight::CIApiRequestFailed
        logger.error "BuildKite API Request failed"
      end

    end

  end

end