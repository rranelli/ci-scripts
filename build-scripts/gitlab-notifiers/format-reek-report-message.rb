#!/usr/bin/env ruby
# Command to pipe through this file: "reek -U --no-color **/*.rb"

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
    .tap { |r| r.push('No smells reported! Good job! :+1:') if r.size == 1 }
    .join("\n\n")
end

def to_warning_presentation
  -> f, w do # homemade currying
    l = w[:line_number]

    w[:message] =~ /(.*)\((.*)\)\s*\[(.*)\]$/
    link = "[#{$2}](#{$3})"
    msg = $1
    "&nbsp;&nbsp; -  #{link} -- #{msg} [L#{l}](#{gitlab_file_url(f, l)})"
  end.curry
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
def gitlab_file_url(file, line)
  File.join(ENV.fetch('GITLAB_PROJECT_URL'), 'blob', `git rev-parse HEAD`.chomp, "#{file}#L#{line}")
end

puts reek_message
