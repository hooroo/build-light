require "awesome_print"
require "pry"
require "build_light/version"
require "build_light/logger"
require "build_light/nil_light"
require "build_light/sound_player"
require "build_light/processor"

module BuildLight

  extend self

  attr_accessor :status_file, :voice_command, :sound_directories, :ci

  def run
    require "build_light/ci/#{BuildLight.ci[:name].downcase}/build"
    require "build_light/ci/#{BuildLight.ci[:name].downcase}/job"
    BuildLight::Processor.new()
  end

  def configure
    yield self
    parameters
  end

  def parameters
    h = {}
    keys.each { |k| h[k.to_sym] = BuildLight.instance_variable_get("@#{k}") }
    return h
  end

  def keys
    keys ||= [:status_file, :voice_command, :sound_directories, :ci]
  end

  def voice_command
    @voice_command ||= "mpg123"
  end

end