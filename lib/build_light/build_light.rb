# require 'blinky'
require 'yaml'

module BuildLight

  class Processor

    def initialize
      @light = Blinky.new.light rescue NilLight.new
      @logger = Logging.logger['BuildLight']
      @config = Settings.load("build_light")!
      binding.pry
      update_status
    end

    def update_status

      begin
        logger.info "Last status: #{last_status}"

        unless last_status == job_result #Status has changed
          logger.info "Updating status to #{job_result}"

          set_light job_result #usb light
          set_status job_result #local status
          announce_failure if job_result == 'failure'
        end

      rescue StandardError => e
        puts 'Setting light :off'
        light.off!
        set_status 'off'
        raise e
      end

    end

    private

    attr_reader :light, :logger, :last_status, :config

    def jenkins
      Jenkins.new( YAML::load( File.open('./config/jenkins.yml') ) )
    end

    # def config
    #   @config ||= YAML::load( File.open('./config/build_light.yml') )
    # end

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
      @last_status ||= File.open(config['status_file'], 'a+').readlines.first
    end

    def set_status status
      logger.info "Setting Status: #{status}"
      File.open(config['status_file'], 'w') { |f| f.write( status ) }
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
      SoundPlayer.play([ SoundPlayer.get_random_file('build_fails') ])
    end

    def announce_failed_build_name name
      SoundPlayer.play([
        SoundPlayer.get_file('announcements', 'build'),
        SoundPlayer.get_file('jobs', name.gsub('-', ' ') ),
        SoundPlayer.get_file('announcements', 'failed')
      ])
    end

    def announce_culprits build
      SoundPlayer.play([
        SoundPlayer.get_file('numbers', build.culprits.size),
        SoundPlayer.get_file('announcements', build.culprits.size == 1 ? "committer" : "committers"),
        SoundPlayer.get_file('announcements', 'drumroll')
      ])
      SoundPlayer.play(build.culprits.inject([]) { | result, element | result << SoundPlayer.get_file('committers', element.split(/(\W)/).map(&:capitalize).join ) })
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