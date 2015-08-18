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
