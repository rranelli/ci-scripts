#!/usr/bin/env bash
exec 2>&1

build-scripts/build success
build-scripts/build failure
build-scripts/build failure_by_broken_post_hook
build-scripts/build failure_by_broken_pre_hook
