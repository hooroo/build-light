module BuildLight

  class Processor

    def initialize(logger: Logging, light_manager: LightManager, ci_auditor: CIAuditor, sound_player: SoundPlayer, config:)
      @config         = config
      @logger         = logger.logger['BuildLight']
      @light          = light_manager.light config.light_manager
      @sound_player   = sound_player.new config
      @auditor        = ci_auditor.new(config.status_file)
    end

    def update!
      begin
        auditor.update!

        if auditor.light_needs_to_change?
          update_light!
          make_announcement
        end

      rescue StandardError => e
        logger.error 'Setting light to: off'
        light.off!
        set_status 'off'
        raise e
      end

    end

    private

    attr_reader :light, :logger, :sound_player, :config

    def update_light!
      logger.info "Setting light to: #{light_message}"
      light.__send__("#{light_message}!")
    end

    def light_message
      case
      when auditor.build_is_active?
        "running"
      when auditor.greenfields?
        "happy"
      else
        auditor.current_state
      end
    end














    def failed_builds
      @failed_builds ||= auditor.failed_builds
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

    def make_announcement

      announce_dramatic_notice
      failed_builds.each do | failed_build |
        announce_failed_build_name failed_build.name
        announce_culprits(failed_build) if failed_build.culprits.size > 0
        `sleep 2`
      end
    end

  end

end
