#!/usr/bin/env ruby

# This script relies on the following environment variables being set:
required_env = %w(
  GITLAB_TOKEN
  GITLAB_ENDPOINT
  GITLAB_PROJECT_NAME
)
exit(1) unless system("env_verify #{required_env.join(' ')}")

require 'gitlab'
token = ENV.fetch('GITLAB_TOKEN')
endpoint = ENV.fetch('GITLAB_ENDPOINT')

Gitlab.configure do |config|
  config.endpoint = endpoint
  config.private_token = token
end

project_name = ENV.fetch('GITLAB_PROJECT_NAME')
project = Gitlab.client
  .projects(search: project_name)
  .detect { |p| p.name == project_name }

puts project.web_url
