require "build_light/version"
require "build_light/settings"
require "build_light/logger"
require "build_light/jenkins"
require "build_light/nil_light"
require "build_light/sound_player"
require "build_light/build_status"
require "build_light/build_light"

module BuildLight

  extend self

  def run(args)
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

end