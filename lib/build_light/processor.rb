module BuildLight

  class Processor

    attr_reader :light, :sound_manager, :auditor

    def initialize(light_manager: nil, ci_auditor: nil, sound_manager: nil, logger: Logging, config:)
      @config         = config
      @logger         = logger.logger['BuildLight']
      @light          = light_manager  || LightManager.light(config.light_manager)
      @auditor        = ci_auditor     || CIAuditor.new(config)
      @sound_manager  = sound_manager  || SoundManager.new(config: config, auditor: auditor)
    end

    def update!
      begin
        auditor.update!
        update_light!(light_message) if auditor.light_needs_to_change?
        sound_manager.make_announcement

      rescue StandardError => e
        update_light!('warning')
        raise e
      end

    end

    private

    attr_reader :logger, :config

    def update_light! message
      logger.info "Setting light to: #{message}"
      light.__send__("#{message}!")
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

  end

end
