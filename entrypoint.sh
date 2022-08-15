#!/bin/bash

set -euxo pipefail

echo "$CRONTAB" > /etc/crontab

exec tini "$@"
