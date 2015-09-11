#!/usr/bin/env ruby

# This script relies on the following environment variables being set:
#  - failure_step          # exported by build-scripts/build
#
#  - build_url             # exported by jenkins
#  - build_display_name    # exported by jenkins
#  - job_name              # exported by jenkins

# Build environment
failure_step = ENV.fetch('failure_step')
success = failure_step == ''

job_name            = File.basename(ENV.fetch('JOB_NAME'))
build_url           = File.join(ENV.fetch('BUILD_URL'), 'console')
build_display_name  = ENV.fetch('BUILD_DISPLAY_NAME')
build_friendly_name = "*#{job_name} - #{build_display_name}*"

if success
  puts <<EOF
Jenkins build status report for **#{job_name}**:

#{build_friendly_name} foi sucesso absoluto! :clap:

[click here](#{build_url}) for more information.
EOF
else
  puts <<EOF
Jenkins build status report for **#{job_name}**:

#{build_friendly_name} **Fracassou miseravelmente** :cop:

Build failed at #{failure_step} step.

[click here](#{build_url}) for more information.
EOF
end
