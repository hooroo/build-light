class BuildStatus
  SUCCESS = 'SUCCESS'
  FAILURE = 'FAILURE'
  DISABLED = 'DISABLED'
  UNKNOWN = 'UNKNOWN'

  def initialize(result = UNKNOWN, has_been_claimed = false)
    @result = result
    @has_been_claimed = has_been_claimed
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
end

