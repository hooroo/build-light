module CI

  module Jenkins

    class CI

      include ::Logger

      attr_reader :build_list, :config

      def initialize config
        @config = config
        @build_list = #implement
        logger.info "Fetching build information for: #{build_list.join(', ')}"
      end

      def builds
        @builds ||= #implement
      end

      def single_build build_name
        Build.new(build_name: build_name, config: config)
      end

      def successful_builds
        builds.select { | build | build.success? }
      end

      def failed_builds
        builds.select { | build | build.failure? }
      end

      def has_no_build_failures?
        failed_builds.empty?
      end

      def has_build_failures?
        !has_no_build_failures?
      end

      private

    end

  end

end