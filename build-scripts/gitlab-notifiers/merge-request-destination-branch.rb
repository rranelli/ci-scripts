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

Gitlab.configure do |config|
  config.endpoint = endpoint
  config.private_token = token
end

project = Gitlab.client
  .projects(search: project_name)
  .detect { |p| p.name == project_name }

merge_request = project && Gitlab.client
  .merge_requests(project.id, state: 'opened')
  .detect { |m| m.source_branch == branch_name }

puts(if merge_request
       "origin/#{merge_request.target_branch}"
     else
       'origin/master'
     end)
