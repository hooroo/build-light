require 'awesome_print'
require 'yaml'
require './lib/jenkins'

jenkins_config_file = './config/jenkins.yml'
config = YAML::load(File.open(jenkins_config_file))
jenkins = Jenkins.new(config)
jenkins.job_list
