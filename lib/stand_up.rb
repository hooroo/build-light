#Add to crontab
#0 9 * * 1,2,3,4,5 ruby lib/stand_up.rb

#Standup song
#30 9 * * 1,2,3,4,5 /bin/bash -c 'export PATH=$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH; RBENV_VERSION=1.9.3-p125; /home/dev/build-light/bin/stand-up >> /home/dev/build-light/log/stand-up.log 2>&1'
def play_tunes(commands = [])
  return unless commands.size > 0

  #Play recorded MP3s
  cmd = "mpg123 #{commands.collect{|cmd| "'#{cmd}'" }.join(' ')}"
  puts "RUNNING COMMAND : #{cmd}"
  `#{cmd}`
end

puts "Playing standup sound effect"

rick_astley       = Random.rand(1 + 50).to_i
meaning_of_life   = 42

puts "... Rollin'? : #{rick_astley}"

if rick_astley == meaning_of_life
  dir = File.expand_path('../../sounds/', __FILE__)
  clip = File.join(dir, 'Rick-Astley-Never-Gonna-Give-You-Up.mp3')
else
  mp3_directory = File.expand_path('../../sounds/cron_jobs/standup/', __FILE__)
  sound_clips = Dir.glob(File.join(mp3_directory, '*.mp3'))
  clip = sound_clips.sample
end

play_tunes( [ clip ] )