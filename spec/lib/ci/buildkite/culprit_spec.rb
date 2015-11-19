require 'spec_helper'

module CI

  module Buildkite

    describe Culprit do

      let(:failed_build)              { JSON.parse File.read("#{Fixtures.path}/buildkite/build/failed_build.json") }
      let(:authorless_failed_build)   { failed_build.tap{ |first_level| first_level[0].tap { |second_level| second_level['creator'] = nil } } }
      let(:metadataless_failed_build) { authorless_failed_build.tap{ |first_level| first_level[0].tap { |second_level| second_level['meta_data'] = nil } } }
      let(:build_data)                { failed_build.first }
      let(:build)                     { double('build', build: build_data) }
      subject                         { described_class.new(build) }

      describe '#culprit' do

        context 'when a culprit is returned from buildkite' do
          it 'names the right person' do
            expect(subject.culprit).to eq 'Michael Chapman'
          end
        end

        context 'when a culprit is _not_ returned from buildkite' do
          let(:build_data) { authorless_failed_build.first }

          context 'but a commit message is' do
            it 'tries to extract the author from the commit message' do
              expect(subject.culprit).to eq 'Tom Elkin'
            end
          end

          context 'but a commit message is not' do
          let(:build_data) { metadataless_failed_build.first }
            it 'falls back to unknown' do
              # binding.pry
              expect(subject.culprit).to eq 'unknown'
            end
          end
        end

      end

      describe '#to_a' do
        it 'returns the culprit nicely wrapped in an array' do
          expect(subject.to_a).to eq [ 'Michael Chapman' ]
        end
      end

    end
  end
end