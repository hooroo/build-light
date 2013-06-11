require 'net/http'
require 'json'
require 'uri'
require 'time'
require 'yaml'

# while implamenting pretty much the same interface as jenkins.rb,
# this needs a different set of reponses and initializers so it will be seperate for now.
# Can be refactored in later

class JenkinsTimer

  def initialize(config)
    @url = config['jenkins_url']
    @username = config['username']
    @api_token = config['api_token']
    @first_job_name = config['first_job_name']
    @jobs = view_jobs(select_view(config['view_to_time'], get_json))
  end

  def parallelised_build_minutes
    longest_successful_build = jobs.inject { |last_job, job| job_duration(last_job) > job_duration(job) ? last_job : job }
    build_number_to_query = longest_successful_build["lastSuccessfulBuild"]["actions"][1]["causes"][0]["upstreamBuild"]
    first_job_for_timed_build = get_specific_job_build(first_job_name, build_number_to_query)

    diff = job_end_time(longest_successful_build) - job_start_time(first_job_for_timed_build)

    (diff/60).round(2)
  end

  def sequential_build_minutes
    total = jobs.inject(0) { |total, job| total + job_duration(job) }
    (total/60).round(2)
  end

  private

  def jobs
    @jobs
  end

  def first_job_name
    @first_job_name
  end

  def get_json(query = nil)
    uri_query = query || "api/json?depth=1&tree=views[name,jobs[name,lastSuccessfulBuild[actions[causes[upstreamBuild]],number,Projects,duration,id]]]"

    api_url = @url

    uri = URI.parse("#{api_url}#{uri_query}")

    http               = Net::HTTP.new(uri.host, uri.port)
    request            = Net::HTTP::Get.new(uri.request_uri)
    request.basic_auth(@username, @api_token)

    response = http.request(request)

    json = JSON.parse(response.body)
  end

  def view_jobs(view)
    view["jobs"]
  end

  def get_specific_job_build(job_name, job_number)
    get_json("job/#{job_name}/#{job_number}/api/json")
  end

  def select_job(name, jobs)
    jobs.select { |job| job["name"] == name }.first
  end

  def parse_jenkins_time(time)
    #ugly method to parse "2013-06-11_15-47-21" to "2013-06-11 15:47:21" to Time object 2013-06-11 15:47:21 +1000
    split_time = time.gsub("_",",").split(",")
    Time.parse(split_time.first + " " + split_time[1].gsub("-",":"))
  end

  def job_duration(job)
    durations_in_ms = job["lastSuccessfulBuild"]["duration"]
    durations_in_ms/1000
  end

  def job_start_time(job)
    start_time = parse_jenkins_time(job["id"])
  end

  def job_end_time(job)
    end_time = parse_jenkins_time(job["lastSuccessfulBuild"]["id"])
    end_time + job_duration(job)
  end

  def select_view(name, json_response)
    json_response["views"].select do |view|
      view["name"] == name
    end.first
  end

end

begin
  config = YAML::load(File.open('./config/jenkins.yml'))
  .merge({'view_to_time' => ENV['VIEW_TO_TIME']})

  timer = JenkinsTimer.new(config)

  puts "Build minutes: ".upcase + timer.parallelised_build_minutes.to_s
  puts "-" * 20
  puts "\n"
  puts "Build minutes if run sequentially: ".upcase + timer.sequential_build_minutes.to_s
  puts "-" * 40
rescue => e
  puts e
end
