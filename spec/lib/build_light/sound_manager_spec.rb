require 'spec_helper'

module BuildLight

  class MockSoundPlayer

    def initialize; end

    def random_clip(clip); return true; end

    def play(args); return true; end

    def clip(arg1, arg2); return true; end
  end

  describe SoundManager do

    let(:broken?)           { true }
    let(:fixed?)            { false }
    let(:greenfields?)      { false }
    let(:build1)            { double(name: 'build1', culprits: culprits) }
    let(:build2)            { double(name: 'build2', culprits: []) }
    let(:culprits)          { [ 'johnno', 'bruce' ] }
    let(:failed_builds)     { [ build1, build2 ] }
    let(:auditor)           { double(build_has_been_broken?: broken?, build_has_been_fixed?: fixed?, failed_builds: failed_builds, first_greenfields?: greenfields?) }
    subject                 { described_class.new(auditor: auditor, sound_player: MockSoundPlayer.new) }

    describe "#make_announcement" do

      before do
        allow(subject).to receive(:announce_breakage)
        allow(subject).to receive(:announce_greenfields)
        allow(subject).to receive(:announce_fix)
        allow(subject).to receive(:announce_check)
        subject.make_announcement
      end

      context "when build has been broken" do

        it "announces the breakage" do
          expect(subject).to have_received :announce_breakage
        end

        it "doesn't announce anything else" do
          expect(subject).to_not have_received :announce_greenfields
          expect(subject).to_not have_received :announce_fix
          expect(subject).to_not have_received :announce_check
        end
      end

      context "when build has been fixed" do

        let(:broken?) { false }
        let(:fixed?)  { true }

        it "announces the fix" do
          expect(subject).to have_received :announce_fix
        end

        it "doesn't announce anything else" do
          expect(subject).to_not have_received :announce_greenfields
          expect(subject).to_not have_received :announce_breakage
          expect(subject).to_not have_received :announce_check
        end
      end

      context "when we reach the first state of greenfields" do

        let(:broken?)       { false }
        let(:fixed?)        { false }
        let(:greenfields?)  { true }

        it "announces the fix" do
          expect(subject).to have_received :announce_greenfields
        end

        it "doesn't announce anything else" do
          expect(subject).to_not have_received :announce_fix
          expect(subject).to_not have_received :announce_breakage
          expect(subject).to_not have_received :announce_check
        end
      end

      context "when a common check takes place" do

        let(:broken?)       { false }
        let(:fixed?)        { false }
        let(:greenfields?)  { false }

        it "announces the fix" do
          expect(subject).to have_received :announce_check
        end

        it "doesn't announce anything else" do
          expect(subject).to_not have_received :announce_fix
          expect(subject).to_not have_received :announce_breakage
          expect(subject).to_not have_received :announce_greenfields
        end
      end
    end

    describe "#announce_fix" do

      after do
        subject.announce_fix
      end

      it "plays an announcement of a fix" do
        expect(subject.sound_player).to receive(:random_clip).with('build_fixes')
      end
    end

    describe "#announce_greenfields" do

      after do
        subject.announce_greenfields
      end

      it "plays an announcement of a first greenfields state" do
        expect(subject.sound_player).to receive(:random_clip).with('greenfields')
      end
    end

    describe "#announce_check" do

      after do
        subject.announce_check
      end

      it "plays an announcement of a first greenfields state" do
        expect(subject.sound_player).to receive(:clip).with('announcements', 'check')
      end
    end

    describe "#announce_fail" do

      after do
        subject.announce_fail
      end

      it "plays an announcement of a first greenfields state" do
        expect(subject.sound_player).to receive(:random_clip).with('build_fails')
      end
    end

    describe "#announce_breakage" do

      after do
        subject.announce_breakage(sleep: false)
      end

      it "plays a random breakage sound" do
        expect(subject).to receive(:announce_fail)
      end

      it "details every broken build" do
        expect(subject).to receive(:announce_failed_build_name).with( build1.name )
        expect(subject).to receive(:announce_failed_build_name).with( build2.name )
      end

      it "names and shames culprits, if any" do
        expect(subject).to receive(:announce_culprits).with culprits #.and_return('sarasa')
        expect(subject).to receive(:announce_culprits).with [] #.and_return('sarasa')
      end

      # context 'with author mappings' do
      #   before do
      #     Configuration.instance.author_mappings = { 'john_something' => ['johnno'] }
      #   end
      # end
    end
  end
end
