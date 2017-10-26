#!/usr/bin/env bash

set -ev

sudo apt-get -qq update

curl -O https://prerelease.keybase.io/keybase_amd64.deb

set +e
# this command will exit with 1, so don't let it take down the job with it
sudo dpkg -i keybase_amd64.deb
set -e

sudo apt-get install -f

sudo apt-get install expect
device_name=$(date +%s%3N)
expect ./setup.expect "${device_name}"

run_keybase
