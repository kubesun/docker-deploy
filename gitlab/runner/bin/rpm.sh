#!/usr/bin/env bash
# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh" | sudo bash
sudo yum install gitlab-runner
# 有时，默认的 skeleton （ skel ） 目录会导致 GitLab Runner 出现问题，并且无法运行作业。
#在 GitLab Runner 12.10 中，我们添加了对特殊变量 - GITLAB_RUNNER_DISABLE_SKEL 的支持，当设置为 true 该变量时，该变量将阻止在创建新创建的用户 $HOME 的目录时使用 skel 。
#从 GitLab 开始，默认情况下将 Runner 14.0 GITLAB_RUNNER_DISABLE_SKEL 设置为 true 。
# 如果出于任何原因需要使用该 skel 目录来填充新创建 $HOME 的目录，则应将 GITLAB_RUNNER_DISABLE_SKEL 该变量显式设置为 false before package installation。例如：
# 对于 RHEL/CentOS/Fedora：
export GITLAB_RUNNER_DISABLE_SKEL=false; sudo -E yum install gitlab-runner
