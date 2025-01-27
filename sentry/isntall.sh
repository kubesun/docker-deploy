#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

# https://develop.sentry.dev/self-hosted/

# Assuming current latest version is 24.1.0
# Current actual version can be acquired from the Releases page on GitHub
VERSION="24.1.0"
git clone https://github.com/getsentry/self-hosted.git
cd self-hosted
git checkout ${VERSION}
sudo ./install.sh
