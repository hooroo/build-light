class BuildStatus
  SUCCESS = 'SUCCESS'
  FAILURE = 'FAILURE'
  DISABLED = 'DISABLED'
  UNKNOWN = 'UNKNOWN'

  def initialize(jenkins_build_json)
    @result = build_result(jenkins_build_json)                || UNKNOWN
    @has_been_claimed = build_claimed?(jenkins_build_json)    || false
    @culprits = build_culprits(jenkins_build_json)            || []
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

  def build_result(build_details_json)
    build_details_json['result']
  end

  def build_claimed?(build_details_json)
    post_build_actions = build_details_json['actions']
    claimed = (post_build_actions.collect { |action| action['claimed'] }).compact.first
    claimed = false if claimed.nil?
    claimed
  end

  def build_culprits(build_details_json)
    culprits = build_details_json['culprits']
    culprits = (culprits.collect { |culprit| culprit['fullName'].gsub('.', ' ').strip }).compact.uniq
    culprits
  end

end

