module BuildLight

  module Settings

    class << self

      @_settings = {}
      attr_reader :_settings

      def load!(config_file, options = {})
        @_settings = YAML::load_file( File.open("./config/#{config_file}.yml") )
        @_settings = @_settings[options[:env].to_sym] if options[:env] && @_settings[options[:env].to_sym]
        @_settings
      end

    end

  end

end