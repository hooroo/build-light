require 'spec_helper'
require 'build_light/ci/buildbox/ci'

module CI

  module Buildbox

    describe CI do

      let(:config)          { { name: 'Buildbox', organisation: 'hooroo', builds: [ 'hotels', 'flightbookings' ], api_token: 'abcd' } }
      let(:failed_build)    { double(success?: false, failure?: true) }
      let(:successful_build)    { double(success?: true, failure?: false) }
      subject(:ci)     { described_class.new config }

      before do
        ci.stub(:assemble_builds).and_return( [ failed_build, failed_build, successful_build, successful_build, successful_build ] )
      end

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

      describe "#failed_builds" do
        it "returns an array of failed build objects" do
          success = ci.failed_builds.select { | build | build.success? }
          failure = ci.failed_builds.select { | build | build.failure? }
          expect(ci.successful_builds.length).to eq 3
          expect(success.length).to eq 0
          expect(failure.length).to eq 2
        end
      end

    end

  end

end
