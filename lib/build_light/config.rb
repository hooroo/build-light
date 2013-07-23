module BuildLight

  class Config

    attr_accessor :status_file, :voice_command

    @_settings = {}

    attr_reader :_settings

    def load!(config_file, options = {})
      @_settings = YAML::load_file( File.join( File.expand_path(__FILE__).split('/')[0..-4].push('config').join('/') , 'build_light.yml') )
      @_settings = @_settings[options[:env].to_sym] if options[:env] && @_settings[options[:env].to_sym]
      @_settings
    end


  end

end