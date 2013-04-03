require 'awesome_print'

class BuildStatus
  SUCCESS = 'SUCCESS'
  FAILURE = 'FAILURE'
  DISABLED = 'DISABLED'
  UNKNOWN = 'UNKNOWN'

  def initialize(job)
    @result = build_result(job)                                      || UNKNOWN
    @has_been_claimed = build_claimed?(job['lastCompletedBuild'])    || false
    @culprits = build_culprits(job['lastCompletedBuild'])            || []
  end


  def disabled?
    @result == DISABLED
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

  def culprits; @culprits; end

  private

  def build_result(job)
    log_job job
    job['lastCompletedBuild']['result'] unless job['lastCompletedBuild'].nil?
  end

  def log_job job
    unless job.nil?
      puts "Job name: #{job['name']}"
      puts "Job started at: #{Time.at(job['lastCompletedBuild']['timestamp']/1000)}"
      puts "Job duration: #{(job['lastCompletedBuild']['duration']/6000.00).round(2)}"
      puts "Job status: #{job['lastCompletedBuild']['result']}"
      puts "="*20
    else
      puts "no job info supplied"
    end
  end

  def build_claimed?(build_details_json)

    post_build_actions = build_details_json.nil? ? [] : build_details_json['actions']
    claimed = (post_build_actions.collect { |action| action['claimed'] }).compact.first
    claimed = false if claimed.nil?
    claimed
  end

  def build_culprits(build_details_json)
    culprits = build_details_json.nil? ? [] : build_details_json['culprits']
    culprits = (culprits.collect { |culprit| culprit['fullName'].gsub('.', ' ').strip }).compact.uniq
    culprits
  end

end

