require 'spec_helper'
require 'build_light/ci/buildbox/build'
require 'build_light/ci/buildbox/job'


module CI

  module Buildbox

    describe Build do

      let(:failed_build)      { JSON.parse File.read("#{Fixtures.path}/buildbox/build/failed_build.json") }
      let(:successful_build)  { JSON.parse File.read("#{Fixtures.path}/buildbox/build/successful_build.json") }
      let(:config)            { { name: 'Buildbox', organisation: 'hooroo', builds: [ 'hotels' ], api_token: 'abcd' } }
      subject(:build)         { described_class.new build_name: 'hotels', config: config }

      before do
        allow_any_instance_of(Octokit::Client).to receive(:commit) do
          {
            sha: "aabbccddee",
            commit: {
              author: {
                name: "Chris Rode",
                email: "chris@hooroo.com",
                date: "2014-11-05 03:08:56 UTC"
              }
            }
          }
        end
      end

      context "given any build" do

        before do
          allow_any_instance_of(described_class).to receive(:api_request) { failed_build }
        end

        it "identifies the last completed build (#build)" do
          expect(build.build['number']).to eq 419
        end

        it "Parses and returns all jobs (#jobs)" do
          classes = build.jobs.map(&:class).uniq
          expect(build.jobs.length).to eq 26
          expect(classes.length).to eq 1
        end

        it "identifies the successful and failed jobs (#failed_jobs) & (#successful_jobs)" do
          expect(build.successful_jobs.length).to eq 20
          expect(build.failed_jobs.length).to eq 6
        end

        it "identifies the unclaimed jobs (#unclaimed_jobs)" do
          expect(build.unclaimed_jobs.length).to eq 26
        end

        it "names and shames the culprits" do
          expect(build.culprits.length).to eq 1
          expect(build.culprits.first).to eq "Chris Rode"
        end

      end

      context "given a failed build" do

        before do
          allow_any_instance_of(described_class).to receive(:api_request) { failed_build }
        end

        it "marks it as failed (#failure?) & (#success?)" do
          expect(build.failure?).to eq true
          expect(build.success?).to eq false
        end

      end

      context "given a successful build" do

        before do
          allow_any_instance_of(described_class).to receive(:api_request) { successful_build }
        end

        it "marks it as successful (#failure?) & (#success?)" do
          expect(build.failure?).to eq false
          expect(build.success?).to eq true
        end

        it "identifies no failed jobs" do
          expect(build.failed_jobs.length).to eq 0
        end

      end

    end

  end

end
