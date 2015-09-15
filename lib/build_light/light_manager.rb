module BuildLight

  class LightManager

    include ::Logger

    def self.light
      new.light
    end

    def initialize
      @config = Configuration.instance
    end

    def light
      light_manager
    end

    private

    attr_reader :config

    def light_manager
      begin
        logger.info "using #{light_manager_class_name} as a light manager"
        Object.const_get(light_manager_class_name).new.light
      rescue StandardError => e
        NilLight.new
      end
    end

    def light_manager_class_name
      klass = config.light_manager[:name].split('')
      klass.shift.upcase + klass.join('')
    end
  end
end