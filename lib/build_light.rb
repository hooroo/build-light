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
                else
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
    mp3_sound_file = File.expand_path("../../sounds/nooo.mp3", __FILE__)
    `mpg123 #{mp3_sound_file}`

    failed_builds = jenkins.failed_builds
    speech_params = "espeak -v en -s 125 -a 1300"

    failed_builds.each do |failed_build_name, failed_build|
      `#{speech_params} "Build #{failed_build_name.gsub('-', ' ')} Has Failed." && sleep 2`
      if failed_build.culprits.size > 0
        `#{speech_params} "Committers to Fix Build." && sleep 1`
        `#{speech_params} "#{failed_build.culprits.join(', ')}"`
      end
      `sleep 3`
    end

  end

  #Setting last_status
  File.open(last_status_file_location, 'w') {|f| f.write(job_result) } unless last_status == job_result
rescue StandardError => e
  puts 'Setting light :off'
  light.off!
  raise e
end

