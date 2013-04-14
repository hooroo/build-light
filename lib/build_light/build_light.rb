# require 'blinky'
require 'yaml'

module BuildLight

  class Processor

    attr_reader :light, :logger, :last_status

    def initialize
      @light = Blinky.new.light rescue NilLight.new
      @logger = Logging.logger['BuildLight']
      update_status
    end

    def jenkins
      Jenkins.new( YAML::load( File.open('./config/jenkins.yml') ) )
    end

    def config
      @config ||= YAML::load( File.open('./config/build_light.yml') )
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

    def dramatic_notice
      logger.info "Playing dramatic notice to announce build failure"
      SoundPlayer.play([ SoundPlayer.get_random_mp3('build_fails') ])
    end


    def announce_failure

      dramatic_notice

      failed_builds.each do |failed_build_name, failed_build|

        SoundPlayer.play([
          SoundPlayer.get_mp3('announcements', 'build'),
          SoundPlayer.get_mp3('jobs', failed_build_name.gsub('-', ' ') ),
          SoundPlayer.get_mp3('announcements', 'failed')
        ])

        if failed_build.culprits.size > 0
          pluralised = failed_build.culprits.size == 1 ? 'committer' : "committers"
          SoundPlayer.play([
            SoundPlayer.get_mp3('numbers', failed_build.culprits.size),
            SoundPlayer.get_mp3('announcements', pluralised),
            SoundPlayer.get_mp3('announcements', 'drumroll')
          ])

          SoundPlayer.play(failed_build.culprits.inject([]) {|result, element| result << SoundPlayer.get_mp3('committers', element.split(/(\W)/).map(&:capitalize).join ) })
        end

        `sleep 2`
      end
    end


    def update_status

      begin

        logger.info "Last status: #{last_status}"

        #Status has changed
        unless last_status == job_result
          logger.info "Updating..."

          #Set USB Light and local status
          set_light job_result
          set_status job_result

          if job_result == 'failure'
            announce_failure
          end
        end

      rescue StandardError => e
        puts 'Setting light :off'
        light.off!
        set_status 'off'
        raise e
      end

    end

  end

end