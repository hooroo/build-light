module BuildLight

  class SoundManager

    include ::Logger

    def initialize config: config, auditor: auditor, sound_player: nil
      @config       = config
      @auditor      = auditor
      @sound_player = sound_player || SoundPlayer.new(config)
    end

    def make_announcement
      true
      # case
      # when auditor.

      # end
    end

    def announce_failure
      announce_dramatic_notice
      audotor.failed_builds.each do | failed_build |
        announce_failed_build_name(failed_build.name)
        announce_culprits(failed_build) if failed_build.culprits.size > 0
        `sleep 2`
      end
    end

    def announce_dramatic_notice
      logger.info "Playing dramatic notice to announce build failure"
      sound_player.play([ sound_player.get_random_file('build_fails') ])
    end

    def announce_failed_build_name name
      sound_player.play([
        sound_player.get_file('announcements', 'build'),
        sound_player.get_file('builds', name.gsub('-', ' ')),
        sound_player.get_file('announcements', 'failed')
      ])
    end

    def announce_culprits build
      sound_player.play([
        sound_player.get_file('numbers', build.culprits.size),
        sound_player.get_file('announcements', build.culprits.size == 1 ? "committer" : "committers"),
        sound_player.get_file('announcements', 'drumroll')
      ])
      sound_player.play(build.culprits.inject([]) { | result, element | result << sound_player.get_file('committers', element) })
    end


    private

    attr_reader :config, :sound_player, :auditor

  end

end