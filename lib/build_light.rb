require 'awesome_print'
require 'pry'

require 'logging'
require 'json'
require 'squinty'
require 'yaml'

require 'build_light/version'
require 'build_light/configuration'
require 'build_light/utilities/deep_hash'
require 'build_light/logger'
require "build_light/light_managers/nil_light"
require 'build_light/errors'
require 'build_light/light_manager'
require 'build_light/ci_manager'
require 'build_light/ci_auditor'
require 'build_light/sound_manager'
require 'build_light/sound_player'
require 'build_light/processor'

module BuildLight

  class BuildLight

    attr_accessor :configuration

    def initialize
      @configuration = Configuration.instance
    end

    def run!
      Processor.new( config: configuration ).update!
    end

    def configure
      yield configuration
      @configuration = configuration
    end

  end

end