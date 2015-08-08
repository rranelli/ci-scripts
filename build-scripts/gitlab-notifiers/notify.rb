#!/usr/bin/env ruby

# This script relies on the following environment variables being set:
#  - GITLAB_TOKEN
#  - GITLAB_ENDPOINT
#  - PROJECT_NAME
#  - GIT_BRANCH

require 'gitlab'

token        = ENV.fetch('GITLAB_TOKEN')
endpoint     = ENV.fetch('GITLAB_ENDPOINT')
project_name = ENV.fetch('PROJECT_NAME')
branch_name  = File.basename(ENV.fetch('GIT_BRANCH'))

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

  if project && merge_request
    Gitlab.client.create_merge_request_comment(
      project.id, merge_request.id, message
    )
  else
    puts 'Couldn\'t find a merge request to report to'
  end
  puts 'Done!'
rescue => e
  puts "Failed! Skipping comment in merge request... \n #{e.message}"
  puts e.backtrace.join("\n")
end
