module BuildLight

  class SoundPlayer

    def initialize
      @config = Settings.load!("build_light")
      @logger = Logging.logger['SoundPlayer']
    end

    def get_file type, command
      find_file(sound_directory(type), command)
    end

    def get_random_file type
      Dir.glob(File.join(sound_directory(type), '*.mp3')).sample
    end

    def play(commands = [])
      collected_commands = []
      commands.each_with_index do |file_location, index|
        if file_location && File.exists?(file_location)
          collected_commands << file_location
        else
          #Missing MP3 file, fall back to unknown
          collected_commands << get_file('announcements', 'unknown')
        end
      end
      make_announcements(collected_commands)
    end

    private

    attr_reader :config, :logger

    def sound_directory type
      File.expand_path("../../../sounds/#{type}/", __FILE__)
    end

    def find_file(directory, command)
      mp3_file = "#{command.to_s.gsub(/([\s\-])/, '_')}.mp3"
      file_path = File.join(directory, mp3_file)
      File.exists?(file_path) ? file_path : nil
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

  end

end