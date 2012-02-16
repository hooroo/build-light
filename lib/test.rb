require 'yaml'
require './lib/jenkins'

def find_mp3(directory, command)
  mp3_file = "#{command.to_s.gsub(' ', '_')}.mp3"
  file_path = File.join(directory, mp3_file)
  File.exists?(file_path) ? file_path : nil
end

def announcement_mp3(command)
  directory = File.expand_path('../../sounds/announcements/', __FILE__)
  find_mp3(directory, command)
end

def job_mp3(command)
  directory = File.expand_path('../../sounds/announcements/jobs/', __FILE__)
  find_mp3(directory, command)
end

def committer_mp3(command)
  directory = File.expand_path('../../sounds/announcements/committers', __FILE__)
  find_mp3(directory, command)
end

def make_announcements(commands = [])
  return unless commands.size > 0

  cmd = "mpg123 #{commands.collect{|cmd| "'#{cmd}'" }.join(' ')}"
  puts cmd
  #Play recorded MP3s from Mac OSX
  `#{cmd}`
end

def make_fallback_announcement(announcement)
  #Old school Espeak (Sounds bad)
  speech_params = "espeak -v en -s 125 -a 1300"
  cmd = "#{speech_params} '#{announcement}'"
  puts cmd
  `#{cmd}`
end

def play_mp3_commands(commands = [])
  collected_commands = []
  commands.each_with_index do |file_location, index|
    if file_location
      #Mp3 file found keep going!
      collected_commands << file_location
    else
      #Missing MP3 file, play whatever can be done in one command, then fire to espeak
      make_announcements(collected_commands)
      make_fallback_announcement(commands[index])

      collected_commands = []
    end
  end
  make_announcements(collected_commands)
end

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

    #Play sound effect on first occurence (randomly chosen from sounds directory)
    puts "Playing failure sound effect"

    mp3_directory = File.expand_path('../../sounds/build_fails/', __FILE__)
    sound_clips = Dir.glob(File.join(mp3_directory, '*.mp3'))


    make_announcements( [ sound_clips.sample ] )

    #Say out loud to committers that have failed the build
    #failed_builds = jenkins.failed_builds

    failed_builds = ['deploy to shrubbery']

    failed_builds.each do |failed_build_name, failed_build|
      play_mp3_commands([announcement_mp3('Build'), job_mp3(failed_build_name.gsub('-', ' ')), announcement_mp3('Has Failed')])

      #if failed_build.culprits.size > 0
        play_mp3_commands([announcement_mp3('Committers to Fix Build')])

        #failed_build.culprits
        culprits = ['James Dunwoody', 'James Fraser', 'Tom']
        play_mp3_commands(culprits.inject([]) {|result, element| result << committer_mp3(element) })
      #end
      `sleep 3`
    end


  #Setting last_status
  #File.open(last_status_file_location, 'w') {|f| f.write(job_result) } unless last_status == job_result
rescue StandardError => e
  puts 'Setting light :off'
#  light.off!
  raise e
end
