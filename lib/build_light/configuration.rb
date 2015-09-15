module BuildLight

  class Configuration
    attr_accessor :status_file, :voice_command, :sound_directories, :ci, :light_manager, :greenfields, :author_mappings

    def initialize
      @status_file          = File.expand_path(File.join('..', '..', '..', 'spec', 'fixtures', 'status', 'last_status.json'), __FILE__)
      @voice_command        = "mpg123"
      @sound_directories    = [ File.expand_path(File.join('..', 'sounds'), __FILE__) ]
      @light_manager        = { name: "squinty" }
      @greenfields          = 2000
      @ci                   = nil
      @author_mappings      = {}
    end
  end

end