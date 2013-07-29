module BuildLight

  class SoundPlayer

    def initialize
      @logger = Logging.logger['SoundPlayer']
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

    attr_reader :logger

    def main_sound_directory
      File.expand_path("../../../sounds/", __FILE__)
    end

    def sound_directories
      [ main_sound_directory ] + BuildLight.sound_directories
    end

    def all_files type
      sound_directories.collect{ |dir| Dir.glob( File.join(dir, type, '*.mp3') ) }.flatten
    end

    def find_file(type, command)
      mp3_file = "#{dehumanise(command)}.mp3"
      file_path = sound_directories.collect{ |dir| f = File.join(dir, type, mp3_file); return f if File.exists? f }.last
      logger.warn "Unknown file #{mp3_file}" unless file_path
      file_path
    end

    def dehumanise str
      str.to_s.downcase.gsub(/([\s\-])/, '_')
    end

    def make_announcements(commands = [])
      return unless commands.size > 0

      #Play recorded MP3s from Mac OSX
      cmd = "#{BuildLight.voice_command} #{commands.collect{|cmd| "'#{cmd}'" }.join(' ')}"
      logger.info "Running Command: #{cmd}"
      exec = %x(#{cmd} &>/dev/null)
      logger.info exec unless exec.empty?
    end

  end

end