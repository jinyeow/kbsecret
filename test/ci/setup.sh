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

# the device name here is just the current timestamp, down to the milliseconds.
# this is sufficient, since the CI is configured to only run one process at a time,
# and devices are deprovisioned immediately after all tests complete.
device_name=$(date +%s%3N)
expect ./test/ci/setup.expect "${device_name}"

run_keybase
