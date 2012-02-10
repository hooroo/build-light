require 'blinky'
require 'yaml'
require './lib/jenkins'

light = Blinky.new.light

begin
  last_status_file_location = "./config/last_status"
  jenkins_config_file = './config/jenkins.yml'
  config = YAML::load(File.open(jenkins_config_file))
  jenkins = Jenkins.new(config)

  job_result = case
                when jenkins.job_statuses.empty?
                  'off'
                when jenkins.has_no_build_failures?
                  'success'
                when jenkins.has_no_unclaimed_builds?
                  'warning'
                when else
                  'failure'
               end

  status_file = File.open(last_status_file_location, 'a+')
  last_status = status_file.readlines.first
  status_file.close

  puts "Last status : #{last_status}"
  puts "Setting light : #{job_result}"

  light.__send__("#{job_result}!")

  if job_result == 'failure' && last_status != 'failure'
    #Play sound effect on first occurence
    puts "Playing failure sound effect"
    `mpg123 ./sounds/nooo.mp3`
  end

  #Setting last_status
  File.open(last_status_file_location, 'w') {|f| f.write(job_result) } unless last_status == job_result
rescue StandardError => e
  puts 'Setting light :off'
  light.off!
  raise e
end

