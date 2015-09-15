require 'spec_helper'

module BuildLight

  describe Processor do

    let(:config)                  { Configuration.instance }
    let(:light_needs_to_change?)  { false }
    let(:auditor)                 { OpenStruct.new( :new => true, :update! => true, :light_needs_to_change? => light_needs_to_change? ) }
    let(:sound_manager)           { OpenStruct.new( :failed_builds => [], :make_announcement => true ) }
    subject(:processor)           { described_class.new(config: config, ci_auditor: auditor, sound_manager: sound_manager) }

    describe "#new" do
      it "receives an instance of the light manager" do
        expect(subject.light).to respond_to :success!
      end

      it "receives an instance of the sound manager" do
        expect(processor.sound_manager).to respond_to :make_announcement
      end

    end

    describe "#update!" do

      before do
        allow(auditor).to receive(:update!)
        allow(sound_manager).to receive(:make_announcement)
        allow(subject).to receive(:update_light!)
        subject.update!
      end

      it "updates the build auditor" do
        expect(subject.auditor).to have_received :update!
      end

      context "when auditor requires no change in light" do

        it "still makes an announcement" do
          expect(subject.sound_manager).to have_received :make_announcement
        end

        it "doesn't update the light" do
          expect(subject).to_not have_received :update_light!
        end

      end

      context "when auditor does require a change in light" do

        let(:light_needs_to_change?) { true }

        it "makes an announcement" do
          expect(subject.sound_manager).to have_received :make_announcement
        end

        it "updates the light" do
          expect(subject).to have_received :update_light!
        end

      end

    end

  end

end
