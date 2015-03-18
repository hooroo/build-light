require 'spec_helper'
require 'build_light/ci/buildkite/ci'

module CI

  module Buildkite

    describe CI do

      let(:config)              { { name: 'Buildkite', organisation: 'hooroo', builds: [ 'hotels', 'flightbookings' ], api_token: 'abcd' } }
      let(:failed_build)        { double(success?: false, failure?: true, running?: false) }
      let(:successful_build)    { double(success?: true, failure?: false, running?: false) }
      let(:running_build)       { double(success?: false, failure?: false, running?: true) }
      let(:assembled_builds)    { [ failed_build, failed_build, successful_build, successful_build, successful_build, running_build, running_build, running_build, running_build ] }
      subject(:ci)              { described_class.new config }

      before { ci.stub(:assemble_builds).and_return assembled_builds }

      describe "#builds" do
        it "returns an array of build objects" do
          expect(ci.builds).to be_a Array
        end
      end

      describe "#successful_builds" do
        it "returns an array of successful build objects" do
          success = ci.successful_builds.select { | build | build.success? }
          failure = ci.successful_builds.select { | build | build.failure? }
          expect(ci.successful_builds.length).to eq 3
          expect(success.length).to eq 3
          expect(failure.length).to eq 0
        end
      end

      describe "#has_no_build_failures?" do

        describe "with build failures" do
          it "returns false, of course" do
            expect(ci.has_no_build_failures?).to eq false
          end
        end

        describe "without build failures" do
          let(:assembled_builds) { [ successful_build, successful_build ] }
          it "returns true, as expected!" do
            expect(ci.has_no_build_failures?).to eq true
          end
        end

      end

      describe "#failed_builds" do
        it "returns an array of failed build objects" do
          success = ci.failed_builds.select { | build | build.success? }
          failure = ci.failed_builds.select { | build | build.failure? }
          expect(ci.successful_builds.length).to eq 3
          expect(success.length).to eq 0
          expect(failure.length).to eq 2
        end
      end

      describe "#has_build_failures?" do

        describe "with build failures" do
          it "returns true, of course" do
            expect(ci.has_build_failures?).to eq true
          end
        end

        describe "without build failures" do
          let(:assembled_builds) { [ successful_build, successful_build ] }
          it "returns false, as expected!" do
            expect(ci.has_build_failures?).to eq false
          end
        end

      end

      describe "#running_builds" do
        it "returns an array of builds that are currently running" do
          running = ci.running_builds.select { | build | build.running? }
          expect(running.length).to eq 4
        end
      end

      describe "#build_in_progress?" do

        describe "with builds indeed in progress" do
          it "returns true, of course" do
            expect(ci.build_in_progress?).to eq true
          end
        end

        describe "without builds in progress" do
          let(:assembled_builds) { [ failed_build, successful_build ] }
          it "returns false, as expected!" do
            expect(ci.build_in_progress?).to eq false
          end
        end

      end

    end
  end
end
