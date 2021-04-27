#!/bin/bash

set -e

cd cloud_controller_ng
bundle install
bundle exec rake rubocop
