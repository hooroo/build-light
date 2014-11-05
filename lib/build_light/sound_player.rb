module BuildLight

  class SoundPlayer

    attr_reader :commands

    def initialize config
      @logger = Logging.logger['SoundPlayer']
      @config = config
    end

    def get_file type, command
      find_file type, command
    end

    def get_random_file type
      all_files(type).sample
    end

    def play(commands = [])
      collected_commands = []
      commands.each_with_index do |file_location, index|
        if file_location && File.exists?(file_location)
          collected_commands << file_location
        else #Missing MP3 file, fall back to unknown
          collected_commands << get_file('announcements', 'unknown')
        end
      end
      make_announcements(collected_commands)
    end

    private

    attr_reader :logger, :config

    def main_sound_directory
      File.expand_path("../../../sounds/", __FILE__)
    end

    def sound_directories
      [ main_sound_directory ] + config.sound_directories
    end

    def all_files type
      sound_directories.collect{ |dir| Dir.glob( File.join(dir, type, '*.mp3') ) }.flatten
    end

    def find_file(type, command)
      mp3_file = "#{dehumanise(command)}.mp3"
      logger.info "Looking for file #{mp3_file} in #{sound_directories.join(',')}"
      file_path = sound_directories.collect{ |dir| f = File.join(dir, type, mp3_file); return f if File.exists? f }.last
      logger.warn "Unknown file #{mp3_file}" unless file_path
      file_path
    end

    def dehumanise str
      str.to_s.downcase.gsub(/([\s\-])/, '_')
    end

    def make_announcements(commands = [])
      return unless commands.size > 0
      cmd = "#{config.voice_command} #{commands.collect{|cmd| "'#{cmd}'" }.join(' ')} &>/dev/null"
      logger.info "Running Command: #{cmd}"
      `#{cmd}`
    end

  end

end