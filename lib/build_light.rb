require 'blinky'
require 'yaml'
require './lib/jenkins'

light = Blinky.new.light

begin
  jenkins_config_file = './config/jenkins.yml'
  config = YAML::load(File.open(jenkins_config_file))
  jenkins = Jenkins.new(config)

  if jenkins.job_statuses.empty?
    puts 'light: off'
    light.off!
  elsif jenkins.has_no_build_failures?
    puts 'light: success'
    light.success!
  elsif jenkins.has_no_unclaimed_builds?
    puts 'light: warning'
    light.warning!
  else
    puts 'light: failure'
    light.failure!
  end
rescue StandardError => e
  puts 'light: off'
  light.off!
  raise e
ensure
  light.close
end

