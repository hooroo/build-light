require 'spec_helper'

module BuildLight

  describe Processor do

    let(:config)                  { Configuration.new }
    let(:light_needs_to_change?)  { false }
    let(:auditor)                 { OpenStruct.new( :new => true, :update! => true, :light_needs_to_change? => light_needs_to_change? ) }
    subject(:processor)           { described_class.new(config: config, ci_auditor: auditor) }

    describe "#new" do
      it "receives an instance of the light manager" do
        expect(subject.light).to respond_to :success!
      end

      it "receives an instance of the sound manager" do
        expect(processor.sound_player).to respond_to :play
      end

    end

    describe "#update!" do

      before do
        allow(auditor).to receive(:update!)
        allow(subject).to receive(:make_announcement)
        allow(subject).to receive(:update_light!)
        subject.update!
      end

      it "updates the build auditor" do
        expect(subject.auditor).to have_received :update!
      end

      context "when auditor requires no change in light" do

        it "doesn't make an announcement" do
          expect(subject).to_not have_received :make_announcement
        end

        it "doesn't update the light" do
          expect(subject).to_not have_received :update_light!
        end

      end

      context "when auditor does require a change in light" do

        let(:light_needs_to_change?) { true }

        it "makes an announcement" do
          expect(subject).to have_received :make_announcement
        end

        it "updates the light" do
          expect(subject).to have_received :update_light!
        end

      end

    end

  end

end
