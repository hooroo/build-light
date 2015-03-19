require 'squinty'
require 'yaml'

module BuildLight

  class Processor

    attr_reader :current_streak_count

    def initialize(logger: Logging, config:)
      @config = config
      @logger = logger.logger['BuildLight']
      @light  = LightManager.light config.light_manager
      @ci     = CIManager.new config.ci
      @sound_player = SoundPlayer.new config
      @current_streak_count = 0
    end

    def update!
      begin
        logger.info "Prior Status: #{prior_status}. Prior Activity: #{prior_activity}. Prior Streak: #{prior_streak_count}"
        logger.info "Current Status: #{current_status}. Current Activity: #{current_activity}"

        update_streak_count
        set_status new_status

        if build_state_has_changed?
          logger.info "Build state has changed."
          set_light light_message
          announce_failure if build_has_failed?
        end

        logger.info "Successful builds: #{ci.successful_builds.length} Failed builds: #{ci.failed_builds.length}"

      rescue StandardError => e
        logger.error 'Setting light to: off'
        light.off!
        set_status 'off'
        raise e
      end

    end

    def set_light message
      logger.info "Setting light to: #{message}"
      light.__send__("#{message}!")
    end

    private

    attr_reader :light, :logger, :status_information, :sound_player, :config, :ci

    def build_state_has_changed?
      (build_is_active? && !build_was_active?) || status_has_changed?
    end

    def status_has_changed?
      current_status != prior_status
    end

    def status_information
      @status_information ||= JSON.parse( IO.read(config.status_file) )
    end

    def current_status
      ci.result
    end

    def prior_status
      status_information['prior_status']
    end

    def current_activity
      ci.activity
    end

    def prior_activity
      status_information['prior_activity']
    end

    def prior_streak_count
      status_information['count'].to_i
    end

    def build_is_active?
      current_activity == 'running'
    end

    def build_was_active?
      prior_activity == 'running'
    end

    def build_is_idle?
      current_activity == 'idle'
    end

    def build_has_failed?
      current_status == 'failure'
    end

    def build_has_succeeded?
      current_status == 'success'
    end

    def greenfields?
      build_has_succeeded? && current_streak_count >= config.greenfields_count
    end

    def set_status status
      status_log = status.to_json
      logger.info "Setting Status: #{status_log}"
      File.open(config.status_file, 'w') { |f| f.write( status_log ) }
    end

    def new_status
      {
        prior_activity: current_activity,
        prior_status: current_status,
        count: current_streak_count
      }
    end

    def update_streak_count
      if build_is_idle?
        @current_streak_count = status_has_changed? ? 1 : prior_streak_count + 1
      else
        @current_streak_count = prior_streak_count
      end
    end

    def light_message
      case
      when build_is_active?
        "running"
      when greenfields?
        "happy"
      else
        current_status
      end
    end

    def failed_builds
      @failed_builds ||= ci.failed_builds
    end

    def announce_dramatic_notice
      logger.info "Playing dramatic notice to announce build failure"
      sound_player.play([ sound_player.get_random_file('build_fails') ])
    end

    def announce_failed_build_name name
      sound_player.play([
        sound_player.get_file('announcements', 'build'),
        sound_player.get_file('builds', name.gsub('-', ' ')),
        sound_player.get_file('announcements', 'failed')
      ])
    end

    def announce_culprits build
      sound_player.play([
        sound_player.get_file('numbers', build.culprits.size),
        sound_player.get_file('announcements', build.culprits.size == 1 ? "committer" : "committers"),
        sound_player.get_file('announcements', 'drumroll')
      ])
      sound_player.play(build.culprits.inject([]) { | result, element | result << sound_player.get_file('committers', element) })
    end

    def announce_failure

      announce_dramatic_notice
      failed_builds.each do | failed_build |
        announce_failed_build_name failed_build.name
        announce_culprits(failed_build) if failed_build.culprits.size > 0
        `sleep 2`
      end
    end

  end

end
