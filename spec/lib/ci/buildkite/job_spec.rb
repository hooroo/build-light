require 'spec_helper'
require 'build_light/ci/buildkite/job'


module CI

  module Buildkite

    describe Job do

      let(:failed_job_json)            { JSON.parse File.read("#{Fixtures.path}/buildkite/job/failed.json") }
      let(:successful_job_json)        { JSON.parse File.read("#{Fixtures.path}/buildkite/job/successful.json") }
      let(:json_data)                  { failed_job_json }
      subject(:job)     { described_class.new json_data }

      context "given a failed job" do

        it "marks it as failed" do
          expect(job.failure?).to eq true
          expect(job.success?).to eq false
        end

        it "marks it as enabled" do
          expect(job.enabled?).to eq true
        end

        it "does not mark it as claimed" do
          expect(job.claimed?).to eq false
        end

      end

    end

  end

end
