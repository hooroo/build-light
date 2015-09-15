module BuildLight

  class SoundManager

    include ::Logger

    attr_reader :sound_player

    def initialize auditor: auditor, sound_player: nil
      @config           = Configuration.instance
      @auditor          = auditor
      @failed_builds    = auditor.failed_builds
      @sound_player     = sound_player || SoundPlayer.new
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
      logger.info "Sound clip: fix"
      sound_player.play([ sound_player.random_clip('build_fixes') ])
    end

    def announce_greenfields
      logger.info "Sound clip: greenfields"
      sound_player.play([ sound_player.random_clip('greenfields') ])
    end

    def announce_check
      logger.info "Sound clip: check"
      sound_player.play([ sound_player.clip('announcements', 'check') ])
    end

    def announce_fail
      logger.info "Sound clip: fail"
      sound_player.play([ sound_player.random_clip('build_fails') ])
    end

    def announce_breakage(sleep: true)
      announce_fail
      auditor.failed_builds.each do | build |
        announce_failed_build_name(build.name)
        announce_culprits( culprits(build) )
        `sleep 2` if sleep
      end
    end


    private

    attr_reader :config, :auditor

    def announce_failed_build_name name
      sound_player.play([
        sound_player.clip('announcements', 'build'),
        sound_player.clip('builds', name.gsub('-', ' ')),
        sound_player.clip('announcements', 'failed')
      ])
    end

    def announce_culprits culprits
       if culprits.any?
        sound_player.play([
          sound_player.clip('numbers', culprits.size),
          sound_player.clip('announcements', (one_culprit?(culprits) ? "committer" : "committers") ),
          sound_player.clip('announcements', 'drumroll')
        ])
        sound_player.play(culprits.inject([]) { | result, culprit | result << sound_player.clip('committers', culprit_name(culprit)) })
      end
    end

    def culprits build
      build.culprits.any? ? build.culprits : []
    end

    def culprit_name culprit
      return culprit_names(culprit)[0] if culprit_names(culprit)
      culprit
    end

    def culprit_names culprit
      config.author_mappings.detect { |key, value| value.include? culprit }
    end

    def one_culprit? culprits
      culprits.size == 1
    end

  end

end