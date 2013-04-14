# require 'blinky'
require 'yaml'

module BuildLight

  class Processor

    attr_reader :light, :logger, :last_status

    def initialize
      @light = Blinky.new.light rescue NilLight.new
      @logger = Logging.logger['BuildLight']
      update_status
    end

    def jenkins
      Jenkins.new( YAML::load( File.open('./config/jenkins.yml') ) )
    end

    def config
      @config ||= YAML::load( File.open('./config/build_light.yml') )
    end

    def job_result
      @job_result ||=
        case
          when jenkins.job_statuses.empty?
            'off'
          when jenkins.has_no_build_failures?
            'success'
          when jenkins.has_no_unclaimed_builds?
            'warning'
          else
            'failure'
        end
    end

    def last_status
      @last_status ||= File.open(config['status_file'], 'a+').readlines.first
    end

    def set_status status
      logger.info "Setting Status: #{status}"
      File.open(config['status_file'], 'w') { |f| f.write( status ) }
    end

    def set_light status
      logger.info "Setting light: #{status}"
      light.__send__("#{status}!")
    end


    def update_status

      begin

        logger.info "Last status: #{last_status}"

        #Status has changed
        unless last_status == job_result
          logger.info "Updating..."

          #Set USB Light and local status
          set_light job_result
          set_status job_result

          if job_result == 'failure'
            #Play sound effect on first occurence (randomly chosen from sounds directory)
            logger.info "Playing failure sound effect"

            mp3_directory = File.expand_path('../../../sounds/build_fails/', __FILE__)
            sound_clips = Dir.glob(File.join(mp3_directory, '*.mp3'))
            make_announcements( [ sound_clips.sample ] )

            #Say out loud to committers that have failed the build
            failed_builds = jenkins.failed_builds

            failed_builds.each do |failed_build_name, failed_build|
              play_mp3_commands([announcement_mp3('build'), job_mp3(failed_build_name.gsub('-', ' ')), announcement_mp3('failed')])
              if failed_build.culprits.size > 0
                pluralised = failed_build.culprits.size == 1 ? 'committer' : "committers"
                play_mp3_commands([announcement_mp3(failed_build.culprits.size), announcement_mp3(pluralised), announcement_mp3('drumroll')])

                play_mp3_commands(failed_build.culprits.inject([]) {|result, element| result << committer_mp3( element.split(/(\W)/).map(&:capitalize).join ) })
              end
              `sleep 2`
            end

          end
        end

      rescue StandardError => e
        puts 'Setting light :off'
        light.off!
        set_status 'off'
        raise e
      end

    end

    def sound_directory types
      File.expand_path("../../sounds/#{types.split(',')}/", __FILE__)
    end

    def find_mp3(directory, command)
      mp3_file = "#{command.to_s.gsub(/([\s\-])/, '_')}.mp3"
      file_path = File.join(directory, mp3_file)
      File.exists?(file_path) ? file_path : nil
    end

    def announcement_mp3(command)
      directory = File.expand_path('../../../sounds/announcements/', __FILE__)
      find_mp3(directory, command)
    end

    def job_mp3(command)
      directory = File.expand_path('../../../sounds/announcements/jobs/', __FILE__)
      find_mp3(directory, command)
    end

    def committer_mp3(command)
      directory = File.expand_path('../../../sounds/announcements/committers', __FILE__)
      find_mp3(directory, command)
    end

    def make_announcements(commands = [])
      return unless commands.size > 0

      #Play recorded MP3s from Mac OSX
      cmd = "#{config['command']} #{commands.collect{|cmd| "'#{cmd}'" }.join(' ')}"
      logger.info "Running Command: #{cmd}"
      `#{cmd}`
    end

    def make_fallback_announcement(announcement)
      return unless announcement && announcement != ''

      #Old school Espeak (Sounds bad)
      speech_params = "espeak -v en -s 125 -a 1300"

      cmd = "#{speech_params} '#{announcement}'"
      logger.info "RUNNING COMMAND : #{cmd}"
      `#{cmd}`
    end

    def play_mp3_commands(commands = [])
      collected_commands = []
      commands.each_with_index do |file_location, index|
        if file_location && File.exists?(file_location)
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

  end

end