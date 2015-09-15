require "build_light/ci/buildkite/build"
require "build_light/ci/buildkite/job"
require "build_light/ci/buildkite/culprit"

module CI

  module Buildkite

    class CI

      include ::Logger

      attr_reader :build_list

      def initialize
        @build_list = BuildLight::Configuration.instance.ci[:builds]
        logger.info "Fetching build information for: #{build_list.join(', ')}"
        # logger.info "Successful builds: #{successful_builds.length} Failed builds: #{failed_builds.length}"
      end

      def builds
        @builds ||= assemble_builds
      end

      def single_build build_name
        Build.new(build_name: build_name)
      end

      def successful_builds
        builds.select { | build | build.success? }
      end

      def failed_builds
        builds.select { | build | build.failure? }
      end

      def running_builds
        builds.select { | build | build.running? }
      end

      def has_no_build_failures?
        failed_builds.empty?
      end

      def has_build_failures?
        !has_no_build_failures?
      end

      def build_in_progress?
        running_builds.any?
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