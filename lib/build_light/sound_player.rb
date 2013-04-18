module BuildLight

  module SoundPlayer

    class << self

      def config
        @config ||= YAML::load( File.open('./config/build_light.yml') )
      end

      def logger
        @logger ||= Logging.logger['SoundPlayer']
      end

      def sound_directory type
        File.expand_path("../../../sounds/#{type}/", __FILE__)
      end

      def get_file type, command
        find_file(sound_directory(type), command)
      end

      def find_file(directory, command)
        mp3_file = "#{command.to_s.gsub(/([\s\-])/, '_')}.mp3"
        file_path = File.join(directory, mp3_file)
        File.exists?(file_path) ? file_path : nil
      end

      def get_random_file type
        Dir.glob(File.join(sound_directory(type), '*.mp3')).sample
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

      def play(commands = [])
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

end