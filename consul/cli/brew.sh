#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

# https://developer.hashicorp.com/consul/downloads

brew tap hashicorp/tap
brew install hashicorp/tap/consul
