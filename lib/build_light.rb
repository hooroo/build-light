require "awesome_print"
require "pry"
require "build_light/version"
require "build_light/utilities/deep_hash"
require "build_light/logger"
require "build_light/errors"
require "build_light/light_manager"
require "build_light/ci_manager"
require "build_light/sound_player"
require "build_light/processor"

module BuildLight

  class BuildLight

    attr_accessor :configuration

    def run!
      validate_ci_data
      Processor.new( config: configuration ).update_status!
    end

    def configure
      configuration ||= Configuration.new
      yield configuration
      @configuration = configuration
    end

    private

    def validate_ci_data
      raise UnspecifiedCIInformation.new('Please enter CI configuration parameters') unless configuration.ci
    end

  end

  class Configuration
    attr_accessor :status_file, :voice_command, :sound_directories, :ci, :light_manager

    def initialize
      @status_file          = File.expand_path(File.join('..', 'last_status'), __FILE__)
      @voice_command        = "mpg123"
      @sound_directories    = [ File.expand_path(File.join('..', 'sounds'), __FILE__) ]
      @light_manager        = { name: "blinkee" }
      @ci                   = nil
    end
  end


end