module CI
  module Buildkite
    class Culprit

      def initialize(build)
        @build = build
      end

      def culprit
        @culprit ||= (culprit_from_build || 'unknown')
      end

      def to_a
        [ culprit ]
      end

      private

      attr_reader :build

      def culprit_from_build
        build.build['creator']['name']
      end
    end
  end
end