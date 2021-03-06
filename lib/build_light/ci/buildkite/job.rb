module CI

  module Buildkite

    class Job

      include ::Logger

      SUCCESS = 'passed'
      FAILURE = /failed/
      UNKNOWN = 'UNKNOWN'
      RUNNING = /running|assigned/

      attr_reader :culprits

      def initialize(job)
        @job                  = job
        if is_valid?
          @result             = job_result || UNKNOWN
          log_job
        else
          logger.warn "CI job is incomplete or invalid"
        end
      end

      def success?
        result == SUCCESS
      end

      def failure?
        !(result =~ FAILURE).nil?
      end

      def claimed?
        job_claimed?
      end

      def enabled?
        # not supported yet
        true
      end

      def running?
        job_result =~ RUNNING
      end

      private

      attr_reader :job, :result

      def is_valid?
        !job.nil?
      end

      def job_result
        job['state'] unless job['state'].nil?
      end

      def job_claimed?
        # not supported yet
        false
      end

      def job_duration
        return "N/A" unless job['finished_at'] && job['started_at']
        "#{( (Time.parse(job['finished_at']) - Time.parse(job['started_at'])) / 60).to_f.round(2)} minutes"
      end

      def log_job
        job_info  = "Name: #{job['name']}. "
        job_info += "Started at: #{job['started_at']} " if job['started_at']
        job_info += "Duration: #{job_duration} "
        job_info += "Status: #{job['state']}"
        logger.info job_info
        # logger.info "Culprits: #{culprits.join(',')}" if failure? and !culprits.empty?
      end

    end
  end
end
