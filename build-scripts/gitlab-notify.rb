#!/usr/bin/env ruby

# This script relies on the following environment variables being set:
#  - BUILD_FAILED
#  - GITLAB_TOKEN
require 'gitlab'

token = ENV.fetch('GITLAB_TOKEN')
endpoint = ENV.fetch('GITLAB_ENDPOINT')

# Build environment
success = ENV.fetch('BUILD_FAILED') != 'true'
project_name = ENV.fetch('PROJECT_NAME')

# Variables exported by Jenkins
# This fixes branch names as origin/master, remotes/origin/master
branch_name = File.basename(ENV.fetch('GIT_BRANCH'))
build_url = File.join(ENV.fetch('BUILD_URL'), 'console')

build_display_name = ENV.fetch('BUILD_DISPLAY_NAME')
job_name = File.basename(ENV.fetch('JOB_NAME'))
build_friendly_name = "*#{job_name} - #{build_display_name}*"

message = if success
            <<EOF
Jenkins job #{build_friendly_name} built successfully!


[click here](#{build_url}) for more information.
EOF
          else
            <<EOF
Jenkins build #{build_friendly_name} **FAILED!**


[click here](#{build_url}) for more information.
EOF
          end

Gitlab.configure do |config|
  config.endpoint = endpoint
  config.private_token = token
end

begin
  puts <<EOF
### Adding a Gitlab comment for project #{project_name}, with result \
[#{success ? 'success' : 'failure'}], with branch #{branch_name}
EOF

  project = Gitlab.client
    .projects(search: project_name)
    .detect { |p| p.name == project_name }

  merge_request = project && Gitlab.client
    .merge_requests(project.id, state: 'opened')
    .detect { |m| m.source_branch == branch_name }

  puts <<EOF
### Acessing gitlab's api with #{Gitlab.user}
Trying to comment in merge request with message: #{message}
...
EOF
  Gitlab.client.create_merge_request_comment(
    project.id, merge_request.id, message
  )
  puts 'Done!'
rescue => e
  puts "Failed! Skipping comment in merge request... \n #{e.message}"
  puts e.backtrace.join("\n")
end
