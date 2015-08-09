#!/usr/bin/env ruby
# Command to pipe through this file: "rubocop --no-color -c $config_file $files_to_analyze"
require 'json'

def rubocop_message(json_string)
  json_result = JSON.parse(json_string)

  json_result['files']
    .reject { |f| f['offenses'] && f['offenses'].empty? }
    .flat_map(&to_file_presentation)
    .unshift("### Rubocop report: :cop:")
    .tap { |r| r.push('No offenses reported! Good job! :clap:') if r.size == 1 }
    .join("\n\n")
end

def to_file_presentation
  -> f do
    path = f['path']

    warnings = f['offenses']
      .sort_by(&offense_line)
      .map(&to_warning(path))

    warnings.unshift("**#{path}**:")
  end
end

def offense_line
  -> o { o['location']['line'] }
end

def to_warning(path)
  -> o do
    line = offense_line[o]
    severity, message, cop = o['severity'], o['message'], o['cop_name']

    <<EOF
&nbsp;&nbsp; - #{severity.capitalize}: #{cop} - #{message} [#L#{line}](#{gitlab_file_url(path, line)})
EOF
  end
end

def gitlab_file_url(file, line)
  File.join(
    ENV.fetch('GITLAB_PROJECT_URL'),
    'blob',
    `git rev-parse HEAD`.chomp,
    "#{file}#L#{line}"
  )
end

puts rubocop_message(STDIN.read)
