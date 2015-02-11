# require 'blinkee'
require 'squinty'
require 'yaml'

module BuildLight

  class Processor

    def initialize(logger: Logging, config:)
      @config = config
      @logger = logger.logger['BuildLight']
      @light  = LightManager.light config.light_manager
      @ci     = CIManager.new config.ci
      @sound_player = SoundPlayer.new config
    end

    def update_status!
      begin
        logger.info "Prior status: #{last_status}"
        unless last_status == ci.result #status has changed
          logger.info "Updating status to #{ci.result}"
          set_light ci.result #usb light
          set_status ci.result #local status
          announce_failure if ci.result == 'failure'
        end
        logger.info "Successful builds: #{ci.successful_builds.length} Failed builds: #{ci.failed_builds.length}"

      rescue StandardError => e
        logger.error 'Setting light: off'
        light.off!
        set_status 'off'
        raise e
      end

    end

    private

    attr_reader :light, :logger, :last_status, :sound_player, :config, :ci

    def last_status
      @last_status ||= File.open(config.status_file, 'a+').readlines.first.gsub(/\s+/, "")
    end

    def set_status status
      logger.info "Setting Status: #{status}"
      File.open(config.status_file, 'w') { |f| f.write( status ) }
    end

    def set_light status
      logger.info "Setting light: #{status}"
      light.__send__("#{status}!")
    end

    def failed_builds
      @failed_builds ||= ci.failed_builds
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

    def announce_failure

      announce_dramatic_notice
      failed_builds.each do | failed_build |
        announce_failed_build_name failed_build.name
        announce_culprits(failed_build) if failed_build.culprits.size > 0
        `sleep 2`
      end
    end

  end

end
