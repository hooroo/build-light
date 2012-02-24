# Jobs
# ====
#
# jenkins.jobs.collect{|k,v| k['name']}
#
# Job list :
#
# ["can-we-ship-it", "can-we-stage-it", "continuous-deploy-to-canary", "deploy-then-migrate-to-production-constructive", "deploy-then-migrate-to-production-destructive", "deploy-then-migrate-to-staging-constructive", "deploy-then-migrate-to-staging-destructive", "deploy-to-demo", "deploy-to-dr", "deploy-to-production", "deploy-to-shrubbery", "deploy-to-staging", "DR replica freshness", "Environment boot", "Environment shutdown", "gatling", "javascript-consumer", "javascript-extranet", "jenkins-backup", "newco-manual", "newco-octopus-acceptance-consumer", "newco-octopus-acceptance-extranet", "newco-octopus-acceptance-unhandled", "newco-octopus-close", "newco-octopus-javascripts", "newco-octopus-metrics", "newco-octopus-prepare", "newco-octopus-smoke", "newco-octopus-specs", "newco-pegasus", "perf-tests", "smoke-tests"
#

#ruby ./lib/generate_sound_files.rb
require 'yaml'
require './lib/jenkins'

STDERR.puts "THIS IS JUST A GENERATOR FOR MAC WITH SEMI DECENT VOICES"

jenkins_config_file = './config/jenkins.yml'
config = YAML::load(File.open(jenkins_config_file))
jenkins = Jenkins.new(config)

job_directory = File.expand_path('../../sounds/announcements/jobs/', __FILE__)
committers_directory = File.expand_path('../../sounds/announcements/committers/', __FILE__)
announcements_directory = File.expand_path('../../sounds/announcements/', __FILE__)
#sound_clips = Dir.glob(File.join(mp3_directory, '*.mp3'))


say_command = "say -v 'Serena' -o /tmp/temp.aiff"

#Generate jobs
job_names = jenkins.jobs.collect{|k,v| k['name'].gsub('-', ' ') }
job_names.each do |job_name|
  mp3_file_target_path = File.join(job_directory, "#{job_name.to_s.gsub(' ', '_')}.mp3")
  cmd = "#{say_command} '#{job_name}' && lame /tmp/temp.aiff #{mp3_file_target_path}"
  puts cmd
  `#{cmd}`
end

#Generate User names
authors = jenkins.successful_builds.collect{|build_name, build| build.culprits}.flatten.uniq.sort
authors.each do |author_name|
  mp3_file_target_path = File.join(committers_directory, "#{author_name.to_s.gsub(' ', '_')}.mp3")
  cmd = "#{say_command} '#{author_name}' && lame /tmp/temp.aiff #{mp3_file_target_path}"
  puts cmd
  `#{cmd}`
end

#Create surrounding announcements
["Build", "Failed", "Committers"].each do |command_string|
  mp3_file_target_path = File.join(announcements_directory, "#{command_string.to_s.gsub(' ', '_')}.mp3")
  cmd = "#{say_command} '#{command_string}' && lame /tmp/temp.aiff #{mp3_file_target_path}"
  puts cmd
  `#{cmd}`
end



