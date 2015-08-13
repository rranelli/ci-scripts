#!/usr/bin/env ruby
require 'json'

def gitlab_file_url(file, line)
  File.join(
    ENV.fetch('GITLAB_PROJECT_URL'),
    'blob',
    `git rev-parse HEAD`.chomp,
    "#{file}#L#{line}"
  )
end

json_result = JSON.parse(STDIN.read, symbolize_names: true)

number_of_warnings = json_result[:scan_info][:security_warnings]
rails_version = json_result[:scan_info][:rails_version]

warnings = json_result[:warnings]

warning_presentation = warnings.group_by { |w| w[:file] }.map do |file, ws|
  ws.map do |w|
    line = w[:line]
    <<EOF
  &nbsp;&nbsp; - **#{w[:warning_type]}**: #{w[:message]} [#L#{line}](#{gitlab_file_url(file, line)})
EOF
  end
    .unshift("#{file}:\n")
    .join("\n")
end

message = <<EOF
### Brakeman report: :cop:

**Rails version**:  #{rails_version}

**Warnings**: #{number_of_warnings}

#{warning_presentation.join("\n")}
EOF

puts message
