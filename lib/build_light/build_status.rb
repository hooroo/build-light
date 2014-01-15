require 'awesome_print'

# module BuildLi

class BuildStatus
  include ::Logger

  SUCCESS = 'SUCCESS'
  FAILURE = 'FAILURE'
  DISABLED = 'DISABLED'
  UNKNOWN = 'UNKNOWN'

  def initialize(job)
    if job_is_valid? job
      @result             = build_result job       || UNKNOWN
      @buildable          = buildable job          || UNKNOWN
      @has_been_claimed   = build_claimed? job     || false
      @culprits           = build_culprits job     || []
      log_job job
    else
      logger.warn "Jenkins job is incomplete or invalid"
    end
  end

  def success?
    @result == SUCCESS
  end

  def failure?
    @result == FAILURE
  end

  def claimed?
    @has_been_claimed
  end

  def claimed?
    @has_been_claimed
  end

  def enabled?
    @buildable
  end

  def culprits; @culprits; end

  private

  def job_is_valid? job
    !job.nil? && job.has_key?('lastCompletedBuild') && !job['lastCompletedBuild'].nil?
  end

  def build_result(job)
    job['lastCompletedBuild']['result'] unless job['lastCompletedBuild'].nil?
  end

  def buildable job
    job['buildable']
  end

  def build_claimed? job
    post_build_actions = job['lastCompletedBuild']['actions'].compact
    claimed = (post_build_actions.collect { |action| action['claimed'] }).compact.first
    claimed = false if claimed.nil?
    claimed
  end

  def build_culprits job
    culprits = job['lastCompletedBuild']['culprits']
    culprits = (culprits.collect { |culprit| culprit['fullName'].gsub('.', ' ').strip }).compact.uniq
    culprits
  end

  def log_job job
    job_info = "Name: #{job['name']}. Started at: #{Time.at(job['lastCompletedBuild']['timestamp']/1000)} "
    job_info += "Duration: #{(job['lastCompletedBuild']['duration']/6000.00).round(2)} Status: #{job['lastCompletedBuild']['result']}"
    logger.info job_info
    logger.info "Culprits: #{culprits.join(',')}" if failure? and !culprits.empty?
  end

end

