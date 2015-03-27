require 'spec_helper'

module BuildLight

  describe CIAuditor do

    let(:config)                { Configuration.new }
    let(:ci)                    { OpenStruct.new(result: current_state, activity: current_activity, failed_builds: failed_builds) }
    let(:failed_builds)         { ['build', 'another'] }
    let(:prior_activity)        { 'idle' }
    let(:current_activity)      { 'idle' }
    let(:prior_state)           { 'failure' }
    let(:current_state)         { 'failure' }
    let(:streak)                { 88 }
    let(:prior)                 { { 'activity' => prior_activity, 'state' => prior_state, 'streak' => streak } }
    subject                     { described_class }
    let(:auditor)               { subject.new(config, ci: ci) }

    before do
      allow_any_instance_of(subject).to receive(:prior).and_return( prior )
    end

    describe "#new" do

      it "receives a greenfields config parameter" do
        expect(auditor.greenfields).to eq 2000
      end

      it "receives a streak count" do
        expect(auditor.streak).to eq streak
      end

    end

    describe "#update!" do

      context "assigned tasks" do

        after do
          auditor.update!
        end

        it "updates the streak" do
          expect(auditor).to receive :update_streak!
        end

        it "persists the status" do
          expect(auditor).to receive :save_status!
        end

      end

      context "when build is idle" do

        before do
          auditor.update!
        end

        context "with a prior failure" do

          context "and a current failure" do

            it "increases the streak count by one" do
              expect(auditor.streak).to eq (streak + 1)
            end

            it "persists the prior state as current" do
              expect(auditor.new_state).to eq current_state
            end

          end

          context "and a current success" do

            let(:current_state) { 'success' }

            it "resets the streak count to 1" do
              expect(auditor.streak).to eq 1
            end

            it "persists the new state as current" do
              expect(auditor.new_state).to eq current_state
            end

          end

        end

        context "with a prior success" do

          let(:prior_state)           { 'success' }
          let(:streak) { 69 }

          context "and a current success" do

            let(:current_state)         { 'success' }

            it "increases the streak count by one" do
              expect(auditor.streak).to eq 70
            end

            it "persists the prior state as current" do
              expect(auditor.new_state).to eq current_state
            end

          end

          context "and a current failure" do

            it "resets the streak count to 1" do
              expect(auditor.streak).to eq 1
            end

            it "persists the new state as current" do
              expect(auditor.new_state).to eq current_state
            end

          end

        end

        context "and a new build starts" do

          let(:current_state)    { 'success' }
          let(:current_activity) { 'running' }

          it "preserves the current streak regardless of the state of the running build" do
            expect(auditor.streak).to eq streak
          end

          it "maintains the prior state regardless of the partial result of the running build" do
            expect(auditor.new_state).to eq prior_state
          end

        end

      end

      context "when build is active" do

        let(:prior_activity) { 'running' }
        let(:streak)         { 34 }

        before do
          auditor.update!
        end

        context "and it's still running" do

          let(:current_activity) { 'running' }

          context "and the partial build state differs from the prior one" do

            let(:current_state) { 'success' }

            it "preserves the prior state as the source of truth" do
              expect(auditor.new_state).to eq prior_state
            end

            it "doesn't update the streak count" do
              expect(auditor.streak).to eq streak
            end

          end

        end

        context "and it finishes running" do

          let(:current_activity) { 'idle' }

          context "and the build state hasn't changed" do

            let(:current_state) { 'failure' }

            it "adds one to the streak count" do
              expect(auditor.streak).to eq (streak + 1)
            end

            it "maintains the prior state" do
              expect(auditor.new_state).to eq prior_state
            end

          end

          context "and the build state has changed" do

            let(:current_state) { 'success' }

            it "resets the streak count to 1" do
              expect(auditor.streak).to eq 1
            end

            it "persists the new state" do
              expect(auditor.new_state).to eq current_state
            end

          end

        end

      end


    end

    describe "#light_needs_to_change?" do

      context "when build is idle" do

        context "and it starts building" do

          let(:current_activity) { 'running' }

          it "returns true" do
            expect(auditor.light_needs_to_change?).to be true
          end

        end

        context "and the state doesn't change" do

          it "returns false" do
            expect(auditor.light_needs_to_change?).to be false
          end

        end

        context "and the state changes" do

          let(:current_state) { 'success' }

          it "returns true" do
            expect(auditor.light_needs_to_change?).to be true
          end

        end

      end

      context "when build is running" do

        let(:prior_activity) { 'running' }

        context "and it's still running" do

          let(:current_activity) { 'running' }

          it "returns false" do
            expect(auditor.light_needs_to_change?).to be false
          end

        end

        context "and it's stopped running" do

          let(:current_activity) { 'idle' }

          context "when the state remains the same in-between builds" do

            it "returns true" do
              expect(auditor.light_needs_to_change?).to be true
            end

          end

          context "when the state changes in-between builds" do

            let(:current_state) { 'success' }

            it "returns true" do
              expect(auditor.light_needs_to_change?).to be true
            end

          end

        end

      end

    end

    describe "#greenfields?" do

      context "when build has failed" do
        let(:current_state) { 'failure' }

        context "and the streak count is high" do
          let(:streak) { 9999 }

          it "doesn't mark the build as being in greenfields state" do
            expect(auditor.greenfields?).to be false
          end

        end

      end

      context "when build has succeeded" do
        let(:current_state) { 'success' }

        context "and the streak count is right under the greenfields count" do
          let(:streak) { (config.greenfields - 1) }

          it "doesn't mark the build as being in greenfields state" do
            expect(auditor.greenfields?).to be false
          end

        end

        context "and the streak count is low" do
          let(:streak) { 2 }

          it "doesn't mark the build as being in greenfields state" do
            expect(auditor.greenfields?).to be false
          end

        end

        context "and the streak count is equal to the greenfields count" do
          let(:streak) { config.greenfields }

          it "marks the build as being in greenfields state" do
            expect(auditor.greenfields?).to be true
          end

        end

        context "and the streak count is pretty damned high" do
          let(:streak) { 9_999_999 }

          it "marks the build as being in greenfields state" do
            expect(auditor.greenfields?).to be true
          end

        end

      end

    end

    describe "#current_state" do

      let(:prior_state) { 'failure' }
      let(:current_state) { 'success' }

      it "equals the result from CI" do
        expect(auditor.current_state).to eq current_state
      end

    end

    describe "#build_is_active?" do

      context "when ci reports build as running" do

        let(:current_activity) { 'running' }

        it "returns true" do
          expect(auditor.build_is_active?).to be true
        end

      end

      context "when ci reports build as idle" do

        let(:current_activity) { 'idle' }

        it "returns false" do
          expect(auditor.build_is_active?).to be false
        end

      end

    end

    describe "#new_state" do

      context "when build is active" do

        let(:current_activity)   { 'running' }

        context "and current state differs from prior state" do

          let(:prior_state)   { 'failure' }
          let(:current_state) { 'success' }

          it "retains the prior state" do
            expect(auditor.new_state).to eq prior_state
          end

        end

      end

      context "when build is idle" do

        let(:current_activity)   { 'idle' }

        context "and current state differs from prior state" do

          let(:prior_state)   { 'failure' }
          let(:current_state) { 'success' }

          it "retains the current state" do
            expect(auditor.new_state).to eq current_state
          end

        end

      end

    end

    describe "#failed_builds" do

      it "reflects failed builds from CI" do
        expect(auditor.failed_builds).to eq failed_builds
      end

    end

    describe "#build_has_been_broken?" do

      let(:current_state) { 'failure' }
      let(:prior_state)   { 'success' }

      context "when not building in in-between checks" do

        let(:current_activity) { 'idle' }

        it "returns true" do
          expect(auditor.build_has_been_broken?).to be true
        end

      end

      context "when building in in-between checks" do

        let(:current_activity) { 'running' }

        it "returns true" do
          expect(auditor.build_has_been_broken?).to be true
        end

      end

      context "when it hastn't been broken" do
        let(:current_state) { 'success' }
        let(:prior_state)   { 'success' }

        it "returns false" do
          expect(auditor.build_has_been_broken?).to be false
        end

      end

      context "when it was already broken" do
        let(:current_state) { 'failure' }
        let(:prior_state)   { 'failure' }

        it "returns false" do
          expect(auditor.build_has_been_broken?).to be false
        end

      end

    end

    describe "#build_has_been_fixed?" do

      let(:prior_state) { 'failure' }
      let(:current_state)   { 'success' }

      context "when not building in in-between checks" do

        let(:current_activity) { 'idle' }

        it "returns true" do
          expect(auditor.build_has_been_fixed?).to be true
        end

      end

      context "when building in in-between checks" do

        let(:current_activity) { 'running' }

        it "returns true" do
          expect(auditor.build_has_been_fixed?).to be true
        end

      end

      context "when it hastn't been fixed" do
        let(:current_state) { 'failure`' }
        let(:prior_state)   { 'failure`' }

        it "returns false" do
          expect(auditor.build_has_been_fixed?).to be false
        end

      end

      context "when it was already fixed" do
        let(:current_state) { 'success' }
        let(:prior_state)   { 'success' }

        it "returns false" do
          expect(auditor.build_has_been_broken?).to be false
        end

      end

    end

    describe "#first_greenfields?" do

      context "with a lower-than-greenfields streak" do

        it "returns false" do
          expect(auditor.first_greenfields?).to be false
        end

      end

      context "with a greater-than-greenfields streak" do

        let(:streak) { 696969 }

        it "returns false" do
          expect(auditor.first_greenfields?).to be false
        end

      end

      context "with a the exact value of greenfields" do

        let(:streak) { config.greenfields }

        it "returns true" do
          expect(auditor.first_greenfields?).to be true
        end

      end

    end

  end

end