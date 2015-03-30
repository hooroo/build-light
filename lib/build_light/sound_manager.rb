module BuildLight

  class SoundManager

    include ::Logger

    attr_reader :sound_player

    def initialize config: config, auditor: auditor, sound_player: nil
      @config           = config
      @auditor          = auditor
      @failed_builds    = auditor.failed_builds
      @sound_player     = sound_player || SoundPlayer.new(config)
    end

    def make_announcement
      case
      when auditor.build_has_been_broken?
        announce_breakage
      when auditor.first_greenfields?
        announce_greenfields
      when auditor.build_has_been_fixed?
        announce_fix
      else
        announce_check
      end
    end

    def announce_fix
      sound_player.play([ sound_player.file('announcements', 'fixed') ])
    end

    def announce_greenfields
      sound_player.play([ sound_player.file('announcements', 'greenfields') ])
    end

    def announce_check
      sound_player.play([ sound_player.file('announcements', 'check') ])
    end

    def announce_breakage(sleep: true)
      dramatic_fail
      auditor.failed_builds.each do | failed_build |
        announce_failed_build_name(failed_build.name)
        announce_culprits(failed_build) if failed_build.culprits.size > 0
        `sleep 2` if sleep
      end
    end

    private

    attr_reader :config, :auditor

    def dramatic_fail
      sound_player.play([ sound_player.random_file('build_fails') ])
    end

    def announce_failed_build_name name
      sound_player.play([
        sound_player.file('announcements', 'build'),
        sound_player.file('builds', name.gsub('-', ' ')),
        sound_player.file('announcements', 'failed')
      ])
    end

    def announce_culprits build
      sound_player.play([
        sound_player.file('numbers', build.culprits.size),
        sound_player.file('announcements', build.culprits.size == 1 ? "committer" : "committers"),
        sound_player.file('announcements', 'drumroll')
      ])
      sound_player.play(build.culprits.inject([]) { | result, element | result << sound_player.file('committers', element) })
    end

  end

end