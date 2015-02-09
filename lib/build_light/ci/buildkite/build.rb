require 'rubygems'
require 'net/http'
require 'json'
require 'open-uri'

module CI

  module Buildkite

    class Build

      include ::Logger

      attr_reader :build, :jobs, :name, :organisation, :culprits, :branch

      URL = 'https://api.buildkite.com/v1'

      def initialize(build_name:, config:)
        @name         = build_name
        @organisation = config[:organisation]
        @branch       = config[:branch] || 'master'
        @api_suffix   = "accounts/#{organisation}/projects/#{name}/builds?api_key=#{config[:api_token]}&branch=#{branch}"
        @build        = fetch_build
        logger.info "Latest fully completed build for project '#{name}' is ##{build['number']}"
        @culprits     = fetch_culprits
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

      private

      attr_reader :api_suffix

      def job job_data
        Job.new job_data
      end

      def fetch_culprits
        if failure?
          [ github_author ].reject{ |x| x.nil? }
        else
          []
        end
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

      def github_author
        author = github_commit_info.get_deep(:commit, :author, :name)
        logger.info "Build break culprit: #{author}" if author
        author
      end

      def github_commit_info
        begin
          octokit.commit("#{organisation}/#{name}", build['commit'])
        rescue => e
          logger.error "Couldn't fetch break culprits from Github"
          {}
        end
      end

      def octokit
        @octokit ||= Octokit::Client.new(:netrc => true)
      end

      def fetch_build
        api_request.sort_by { | b | Time.parse(b["created_at"]) }.reverse.detect{ | build | build['finished_at'] && build['state'] != 'canceled' }
      end

      def api_request
        api_url = "#{URL}/#{api_suffix}"
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