require "awesome_print"
require "pry"

require "json"

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
      Processor.new( config: configuration ).update!
    end

    def configure
      configuration ||= Configuration.new
      yield configuration
      @configuration = configuration
    end

  end

  class Configuration
    attr_accessor :status_file, :voice_command, :sound_directories, :ci, :light_manager, :greenfields_count

    def initialize
      @status_file          = File.expand_path(File.join('..', 'last_status.json'), __FILE__)
      @voice_command        = "mpg123"
      @sound_directories    = [ File.expand_path(File.join('..', 'sounds'), __FILE__) ]
      @light_manager        = { name: "squinty" }
      @greenfields_count    = 2000
      @ci                   = nil
    end
  end


end