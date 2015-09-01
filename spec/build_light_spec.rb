require 'spec_helper'

module BuildLight


  describe BuildLight do

    let(:config)                { Configuration.new }
    let(:new_config)            { nil }
    subject                     { described_class.new }

    describe "#configure" do

      context "when specifying overriding configuration parameters" do

        before do
          subject.configure do |config|
            config.status_file = 'my_file'
            config.sound_directories = [ 'eeny', 'meeny', 'miney', 'mo' ]
            config.ci = { name: 'ci_service', custom_param: 'a_param' }
            config.greenfields = 6969
            config.light_manager = { name: 'LightMan(tm)' }
            config.voice_command = 'say'
          end
        end

        it "overrides the defaults" do
          expect(subject.configuration.status_file).to eq 'my_file'
          expect(subject.configuration.sound_directories).to eq([ 'eeny', 'meeny', 'miney', 'mo' ])
          expect(subject.configuration.ci).to eq({ name: 'ci_service', custom_param: 'a_param' })
          expect(subject.configuration.greenfields).to eq 6969
          expect(subject.configuration.light_manager).to eq({ name: 'LightMan(tm)' })
          expect(subject.configuration.voice_command).to eq 'say'
        end
      end

      context "when not overriding" do

        before do
          subject.configure { |config| config }
        end

        it "returns the default configuration values" do
          expect(subject.configuration.ci).to be nil
          expect(subject.configuration.greenfields).to eq 2000
          expect(subject.configuration.light_manager).to eq({ name: 'squinty' })
          expect(subject.configuration.voice_command).to eq 'mpg123'
        end
      end
    end
  end
end