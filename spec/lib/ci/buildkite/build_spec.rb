require 'spec_helper'

module CI

  module Buildkite

    describe Build do

      let(:failed_build)      { JSON.parse File.read("#{Fixtures.path}/buildkite/build/failed_build.json") }
      let(:successful_build)  { JSON.parse File.read("#{Fixtures.path}/buildkite/build/successful_build.json") }
      let(:running_build)     { JSON.parse File.read("#{Fixtures.path}/buildkite/build/running_build.json") }
      subject(:build)         { described_class.new build_name: 'hotels' }

      context "given any build" do

        before do
          BuildLight::Configuration.instance.ci = { name: 'Buildkite', organisation: 'hooroo', builds: [ 'hotels' ], api_token: 'abcd' }
          allow_any_instance_of(described_class).to receive(:api_request) { failed_build }
        end

        it "identifies the last build (#build)" do
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
          expect(build.culprits.first).to eq "Michael Chapman"
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

        it "it doesn't identify it as running" do
          expect(build.running?).to eq false
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

        it "it doesn't identify it as running" do
          expect(build.running?).to eq false
        end
      end

      context "given a running build" do

        before do
          allow_any_instance_of(described_class).to receive(:api_request) { running_build }
        end

        it "it identifies a partial success or failure state (#failure?) & (#success?)" do
          expect(build.failure?).to eq false
          expect(build.success?).to eq true
        end

        it "it identifies it as running" do
          expect(build.running?).to eq true
        end
      end
    end
  end
end
