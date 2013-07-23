require 'blinky'
require 'yaml'

module BuildLight

  class Processor

    def initialize
      @light = Blinky.new.light rescue NilLight.new
      @logger = Logging.logger['BuildLight']
      @sound_player = SoundPlayer.new
      update_status
    end

    def update_status

      begin
        logger.info "Last status: #{last_status}"

        unless last_status == job_result #status has changed
          logger.info "Updating status to #{job_result}"
          set_light job_result #usb light
          set_status job_result #local status
          announce_failure if job_result == 'failure'
        end

      rescue StandardError => e
        logger.error 'Setting light :off'
        light.off!
        set_status 'off'
        raise e
      end

    end

    private

    attr_reader :light, :logger, :last_status, :sound_player, :jenkins

    def jenkins
      @jenkins ||= Jenkins.new( BuildLight.ci )
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
      @last_status ||= File.open(BuildLight.status_file, 'a+').readlines.first
    end

    def set_status status
      logger.info "Setting Status: #{status}"
      File.open(BuildLight.status_file, 'w') { |f| f.write( status ) }
    end

    def set_light status
      logger.info "Setting light: #{status}"
      light.__send__("#{status}!")
    end

    def failed_builds
      @failed_builds ||= jenkins.failed_builds
    end

    def announce_dramatic_notice
      logger.info "Playing dramatic notice to announce build failure"
      sound_player.play([ sound_player.get_random_file('build_fails') ])
    end

    def announce_failed_build_name name
      sound_player.play([
        sound_player.get_file('announcements', 'build'),
        sound_player.get_file('jobs', name.gsub('-', ' ') ),
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

      failed_builds.each do | name, failed_build |
        announce_failed_build_name name
        announce_culprits(failed_build) if failed_build.culprits.size > 0
        `sleep 2`
      end
    end

  end

end