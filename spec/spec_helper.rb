require 'pry-byebug'
require 'awesome_print'
require 'build_light'
require 'build_light/ci/buildkite/ci'

class Fixtures
  def self.path
    File.expand_path(File.join('..', 'fixtures'), __FILE__)
  end
end

Logging.logger.root.level = :error