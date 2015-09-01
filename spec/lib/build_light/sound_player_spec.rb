require 'spec_helper'

module BuildLight

  describe SoundPlayer do

    let(:config)            { Configuration.new }
    let(:file_type)         { "build_fails" }
    let(:file_name)         { "hell_naw" }
    let(:local_path)        { File.expand_path(File.join('../../../..'), __FILE__) }
    subject(:sound_player)  { described_class.new(config) }


    describe "#file" do
      it 'finds a file from the specified sound directories' do
        file = sound_player.clip( file_type, file_name )

        expect( file ).to eq "#{local_path}/sounds/build_fails/hell_naw.mp3"

      end
    end

    describe "#play" do

      # skip "this needs to be properly tested"

      # before do
      #   # allow(sound_player.play).to receive(:`)
      # end

      # let(:commands) {
      #   [
      #     sound_player.clip('announcements', 'build'),
      #     sound_player.clip('announcements', 'unknown'),
      #     sound_player.clip('announcements', 'failed')
      #   ]
      # }

      # let(:arguments) { "mpg123 #{commands.map { |k| "'#{k}'" }.join(' ')} &>/dev/null" }

      # it "plays a series of sounds in the specified order using a shell command" do
      #   expect($?.success?).to be true
      # end

    end


  end
end
