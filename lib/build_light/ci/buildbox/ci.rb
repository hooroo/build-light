module CI

  module Buildbox

    class CI

      include ::Logger

      attr_reader :build_list

      def initialize config
        @config = config
        @build_list = config.builds
        logger.info "LOG SOMETHINGGGGGGGGGGGGG"
      end

      def builds
        @builds ||= assemble_builds
      end

      def single_build build_name
        Build.new build_name, config
      end

      def successful_builds
        builds.select { | build | build.success? }
      end

      def failed_builds
        build_statuses.select { | build | build.failure? }
      end

      def has_no_build_failures?
        failed_builds.empty?
      end

      def has_build_failures?
        !has_no_build_failures?
      end

      private

      def assemble_builds
        build_objects = []
        build_list.each do |build_name|
          build_objects.push(single_build build_name)
        end
        build_objects
      end

    end

  end

end