module CI

  module Buildbox

    class Job

      include ::Logger

      SUCCESS = 'passed'
      FAILURE = 'failed'
      UNKNOWN = 'UNKNOWN'

      attr_reader :culprits

      def initialize(job)
        @job                  = job
        if job_is_valid?
          @result             = build_result       || UNKNOWN
          @culprits           = build_culprits
          log_job
        else
          logger.warn "CI job is incomplete or invalid"
        end
      end

      def success?
        result == SUCCESS
      end

      def failure?
        result == FAILURE
      end

      def claimed?
        build_claimed?
      end

      def enabled?
        # not supported yet
        true
      end

      private

      attr_reader :job, :result

      def job_is_valid?
        !job.nil?
      end

      def build_result
        job['state'] unless job['state'].nil?
      end

      def build_claimed?
        # not supported yet
        false
      end

      def build_culprits
        # not implemented yet
        []
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
