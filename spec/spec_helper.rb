require 'pry-debugger'
require 'awesome_print'
require 'json'
require 'build_light'

class Fixtures
  def self.path
    File.expand_path(File.join('..', 'fixtures'), __FILE__)
  end
end

Logging.logger.root.level = :error