#!/usr/bin/env ruby

# This script relies on the following environment variables being set:
required_env = %w(
  GITLAB_TOKEN
  GITLAB_ENDPOINT
  GITLAB_PROJECT_NAME
  GITLAB_BRANCH
)
required_env.each { |e| ENV.fetch(e) }

require 'gitlab'

token        = ENV.fetch('GITLAB_TOKEN')
endpoint     = ENV.fetch('GITLAB_ENDPOINT')
project_name = ENV.fetch('GITLAB_PROJECT_NAME')
branch_name  = File.basename(ENV.fetch('GITLAB_BRANCH'))

message = STDIN.read

Gitlab.configure do |config|
  config.endpoint = endpoint
  config.private_token = token
end

begin
  puts "Trying to add a Gitlab comment for project #{project_name} and #{branch_name}"

  project = Gitlab.client
    .projects(search: project_name)
    .detect { |p| p.name == project_name }

  merge_request = project && Gitlab.client
    .merge_requests(project.id, state: 'opened')
    .detect { |m| m.source_branch == branch_name }

  puts <<EOF
Trying to comment in merge request with message:

#{message}
EOF

  return puts 'Couldn\'t find a merge request.' unless project && merge_request

  mr_url = File.join(
    endpoint,
    'projects', project.id.to_s,
    'merge_requests', merge_request.id.to_s
  )

  make_notes_url = -> page { File.join(mr_url, "notes?page=#{page}&private_token=#{token}") }
  NotDoneYet = Class.new(RuntimeError)

  page = 1
  notes = []
  begin
    notes_url = make_notes_url[page]

    uri = URI.parse(notes_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)

    notes += JSON.parse(response.body)

    fail NotDoneYet if response['link'] =~ /rel="next"/
  rescue
    page += 1
    retry
  end

  note_to_delete = notes.detect do |n|
    n['body'].lines.first == message.lines.first
  end

  if note_to_delete
    note_to_delete['body'] = '---'
    note_url = File.join(
      mr_url,
      "notes/#{note_to_delete['id']}?private_token=#{token}"
    )
    request = Net::HTTP::Delete.new(URI.parse(note_url).request_uri)
    http.request(request)
  end

  Gitlab.client.create_merge_request_comment(
    project.id, merge_request.id, message
  )

  puts 'Done!'
rescue => e
  puts "Failed! Skipping comment in merge request... \n #{e.message}"
  puts e.backtrace.join("\n")
end
