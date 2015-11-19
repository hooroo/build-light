module CI
  module Buildkite
    class Culprit

      AUTHOR_FROM_COMMIT_MESSAGE_REGEX = /Author: ([A-Za-z\s]+) </

      def initialize(build)
        @build = build
      end

      def culprit
        @culprit ||= (culprit_from_author || cuprit_from_commit_message || 'unknown')
      end

      def to_a
        [ culprit ]
      end

      private

      attr_reader :build

      def culprit_from_author
        build.build['creator']['name'] if build.build['creator']
      end

      def cuprit_from_commit_message
        match = AUTHOR_FROM_COMMIT_MESSAGE_REGEX.match(commit_message)
        match ? match[1].strip : nil
      end

      def commit_message
        build.build['meta_data'] ? build.build['meta_data']['buildkite:git:commit'] : nil
      end

    end
  end
end