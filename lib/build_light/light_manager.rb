require "build_light/light_managers/nil_light"

module BuildLight

  class LightManager

    include ::Logger

    def self.light config
      new(config).light
    end

    def initialize config
      @config = config
    end

    def light
      light_manager
    end

    private

    attr_reader :config

    def light_manager
      begin
        require_light_manager
        logger.info "using #{light_manager_class_name} as a light manager"
        Object.const_get(light_manager_class_name).new.light
      rescue StandardError => e
        NilLight.new
      end
    end

    def require_light_manager
      require config[:name]
    end

    def light_manager_class_name
      klass = config[:name].split('')
      klass.shift.upcase + klass.join('')
    end

  end

end