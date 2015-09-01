module CI
  module Buildkite
    class Culprit

      def initialize(build)
        @build = build
      end

      def culprit
        @culprit ||= culprit_from_build
      end

      def to_a
        [ culprit ]
      end

      private

      attr_reader :build

      def culprit_from_build
        return build.build['creator']['name'] if build.build['creator']
        'unknown'
      end
    end
  end
end