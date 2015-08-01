#!/usr/bin/env ruby
# Command to pipe through this file: "reek -U --no-color **/*.rb"
# TODO: figure out how to avoid analysing the whole project for comment

#########################
# Parsing reek´s output #
#########################
def reek_message
  is_new_analysis = -> x { x =~ /([^.]*\.rb) -- \d+ warnings:$/ }
  is_warning =  -> x { x =~ /\[(\d+)\]:(.*)$/ }

  analysis = []
  STDIN.each_line do |x|
    case x
    when is_new_analysis then analysis << [$1, []]
    when is_warning then analysis.last.last << { line_number: $1, message: $2 }
    end
  end

  analysis
    .map(&to_file_presentation)
    .unshift("#### Reek smells report: ")
    .join("\n\n")
end

def to_warning_presentation
  -> f do -> w do # homemade currying
      l = w[:line_number]

      w[:message] =~ /(.*)\((.*)\)\s*\[(.*)\]$/
      link = "[#{$2}](#{$3})"
      msg = $1
      "&nbsp;&nbsp; -  #{link} -- #{msg} [L#{l}](#{gitlab_file_url(f, l)})"
    end
  end
end

def to_file_presentation
  -> ((f, ws)) do
    warnings = ws
      .sort_by { |x| x[:line_number].to_i }
      .map(&to_warning_presentation[f])
      .join("\n\n")

    <<EOF
File: **#{f}**

#{warnings}

EOF
  end
end

######################
# Gitlab interaction #
######################
require 'gitlab'
token = ENV.fetch('GITLAB_TOKEN')
endpoint = ENV.fetch('GITLAB_ENDPOINT')

Gitlab.configure do |config|
  config.endpoint = endpoint
  config.private_token = token
end

def gitlab_file_url(file, line)
  File.join($PROJECT_URL, 'blob', `git rev-parse HEAD`.chomp, "#{file}#L#{line}")
end

project_name = ENV.fetch('PROJECT_NAME')
project = Gitlab.client
  .projects(search: project_name)
  .detect { |p| p.name == project_name }

$PROJECT_URL = project.web_url

branch_name = File.basename(ENV.fetch('GIT_BRANCH'))
merge_request = project && Gitlab.client
  .merge_requests(project.id, state: 'opened')
  .detect { |m| m.source_branch == branch_name }

###############
# Actual call #
###############
Gitlab.client.create_merge_request_comment(
  project.id, merge_request.id, reek_message
)
