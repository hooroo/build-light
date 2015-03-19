require 'spec_helper'
require 'build_light'
require 'build_light/processor'

module BuildLight

  describe Processor do

    let(:current_activity)    { 'idle' }
    let(:prior_activity)      { 'idle' }
    let(:prior_status)        { 'failure' }
    let(:streak)              { 10 }
    let(:status_information)  {  { 'prior_activity' => prior_activity, 'prior_status' => prior_status, 'count' => streak } }

    let(:config)              { Configuration.new }
    let(:ci)                  { double(CIManager.new(config.ci)) }
    subject(:processor)       { described_class.new(config: config) }

    before do
      config.ci = { name: 'Buildkite', organisation: 'hooroo', builds: [ 'hotels' ], api_token: 'abcd' }
      processor.stub_chain(:ci, :successful_builds, :length).and_return 2
      processor.stub_chain(:ci, :failed_builds, :length).and_return 2
      processor.stub(:set_light) { true }
      processor.stub(:set_status) { true }
      processor.stub(:announce_failure) { true }
    end

    describe "#new" do
      it "sets the current streak counter to zero" do
        expect(processor.current_streak_count).to eq 0
      end
    end

    describe "#update!" do

      before do
        processor.stub_chain(:ci, :result).and_return "failure"
        processor.stub_chain(:ci, :activity).and_return current_activity
        processor.stub(:status_information)  { status_information }
        processor.update!
      end

      context "when latest build is idle (not building)" do

        context "when there's no change in status" do

          it "sets the status" do
            expect(processor).to have_received :set_status
          end

          it "doesn't action the light" do
            expect(processor).to_not have_received :set_light
            expect(processor).to_not have_received :announce_failure
          end

          it "increments the prior status' streak count of builds on a row" do
            expect(processor.current_streak_count).to eq (streak + 1)
          end

        end

        context "when there _is_ a change in status" do

          let(:prior_status) { "success" }

          it "actions the light and changes the status" do
            expect(processor).to have_received :set_light
            expect(processor).to have_received :set_status
            expect(processor).to have_received :announce_failure
          end

          it "resets the streak count of builds on a row to 1" do
            expect(processor.current_streak_count).to eq 1
          end

        end

      end

      context "when latest build is active (building)" do

        let(:current_activity) { 'running' }

        context "when there's no change in status" do
          let(:prior_activity)    { 'running' }

          it "sets the status" do
            expect(processor).to have_received :set_status
          end

          it "doesn't action the light" do
            expect(processor).to_not have_received :set_light
            expect(processor).to_not have_received :announce_failure
          end

          it "sets the current streak to be the same as the prior one" do
            expect(processor.current_streak_count).to eq streak
          end

        end

        context "when there _is_ a change in status" do

          let(:prior_activity)    { 'idle' }

          it "actions the light and changes the status" do
            expect(processor).to have_received :set_light
            expect(processor).to have_received :set_status
            expect(processor).to have_received :announce_failure
          end

          it "sets the current streak to be the same as the prior one" do
            expect(processor.current_streak_count).to eq streak
          end

        end

      end

    end


  end
end
