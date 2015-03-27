module BuildLight

  class CIAuditor

    include ::Logger

    RUNNING = 'running'
    FAILED  = 'failure'

    attr_reader :greenfields, :streak, :new_state

    def initialize config, ci: nil
      @persistor      = config.status_file
      @ci             = ci || CIManager.new(config.ci)
      @greenfields    = config.greenfields
      @streak         = prior['streak']
      logger.info "Prior state: #{prior_state}. Prior activity: #{prior_activity}. Prior streak: #{streak}"
    end

    def update!
      logger.info "Current state: #{current_state}. Current activity: #{current_activity}"
      update_streak!
      save_status!
    end

    def light_needs_to_change?
      activity_has_changed? || state_has_changed?
    end

    def greenfields?
      build_has_succeeded? && streak >= greenfields
    end

    def current_state
      ci.result
    end

    def build_is_active?
      current_activity == RUNNING
    end

    def new_state
      build_is_active? ? prior_state : current_state
    end

    def failed_builds
      ci.failed_builds
    end

    private

    attr_reader :persistor, :ci, :prior

    def state_has_changed?
      (build_has_failed? && build_had_succeeded?) || (build_has_succeeded? && build_had_failed?)
    end

    def activity_has_changed?
      build_has_become_active? || build_has_become_idle?
    end

    def build_has_become_active?
      build_is_active? && build_was_idle?
    end

    def build_has_become_idle?
      build_is_idle? && build_was_active?
    end

    def build_is_still_active?
      build_is_active? && build_was_active?
    end

    def build_is_still_idle?
      build_is_idle? && build_was_idle?
    end

    def build_has_failed?
      current_state == FAILED
    end

    def build_has_succeeded?
      !build_has_failed?
    end

    def build_had_failed?
      prior_state == FAILED
    end

    def build_had_succeeded?
      !build_had_failed?
    end

    def build_is_idle?
      !build_is_active?
    end

    def build_was_active?
      prior_activity == RUNNING
    end

    def build_was_idle?
      !build_was_active?
    end

    def prior_state
      prior['state']
    end

    def current_activity
      ci.activity
    end

    def prior_activity
      prior['activity']
    end

    def prior
      @prior ||= JSON.parse( IO.read(persistor) )
    end

    def update_streak!
      if build_is_idle?
        @streak = state_has_changed? ? 1 : streak + 1
      end
      logger.info "Streak: #{streak}"
    end

    def save_status!
      record_log = record.to_json
      logger.info "Persisting: #{record_log}"
      File.open(persistor, 'w') { |f| f.write( record_log ) }
    end

    def record
      {
        activity: current_activity,
        state: new_state,
        streak: streak
      }
    end

  end

end