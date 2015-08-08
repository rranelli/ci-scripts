#!/usr/bin/env ruby
require 'gitlab'
token = ENV.fetch('GITLAB_TOKEN')
endpoint = ENV.fetch('GITLAB_ENDPOINT')

Gitlab.configure do |config|
  config.endpoint = endpoint
  config.private_token = token
end

project_name = ENV.fetch('PROJECT_NAME')
project = Gitlab.client
  .projects(search: project_name)
  .detect { |p| p.name == project_name }

puts project.web_url
