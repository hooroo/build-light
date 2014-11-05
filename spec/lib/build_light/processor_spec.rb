require 'spec_helper'
require 'build_light/processor'

module BuildLight

  describe Processor do

    let(:last_status)       { "failure" }
    let(:config)            { Configuration.new }
    subject(:processor)     { described_class.new(config: config) }

    before do
      config.ci = { name: 'Buildbox', organisation: 'hooroo', builds: [ 'hotels' ], api_token: 'abcd' }
      processor.stub_chain(:ci, :successful_builds, :length).and_return 2
      processor.stub_chain(:ci, :failed_builds, :length).and_return 2
      processor.stub(:set_light) { true }
      processor.stub(:set_status) { true }
      processor.stub(:announce_failure) { true }
    end

    describe "#update_status!" do

      before do
        processor.stub(:ci_result)    { "failure" }
        processor.stub(:last_status)  { last_status }
      end

      context "when there's no change in status" do

        it "doesn't action the light or change the status" do
          processor.update_status!
          expect(processor).to_not have_received :set_light
          expect(processor).to_not have_received :set_status
          expect(processor).to_not have_received :announce_failure
        end

      end

      context "when there _is_ a change in status" do

        let(:last_status) { "success" }

        it "doesn't action the light or change the status" do
          processor.update_status!
          expect(processor).to have_received :set_light
          expect(processor).to have_received :set_status
          expect(processor).to have_received :announce_failure
        end

      end


    end


  end
end
