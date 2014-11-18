module BuildLight

  class CIManager

    include ::Logger

    def initialize config
      @config = config
    end

    def result
      @result ||=
        case
          when ci_class.builds.empty?
            'off'
          when ci_class.has_no_build_failures?
            'success'
          # decomissioning for now!
          # when ci_class.has_no_unclaimed_jobs?
          #   'warning'
          else
            'failure'
        end
    end

    def successful_builds
      ci_class.successful_builds
    end

    def failed_builds
      ci_class.failed_builds
    end

    private

    attr_reader :config

    def ci_class
      @ci_class ||= ci_class_name.new( config.ci )
    end

    def require_ci_manager
      require "build_light/ci/#{config[:name].downcase}/ci"
      require "build_light/ci/#{config[:name].downcase}/build"
      require "build_light/ci/#{config[:name].downcase}/job"
    end

    def ci_class_name
      "CI::#{config.ci[:name]}::CI".split('::').inject(Object) { | o,c | o.const_get c }
    end


  end

end