#!/bin/sh
set -x

config="/mnt/data/docker-gitlab-158/config"
logs="/mnt/data/docker-gitlab-158/logs"
data="/mnt/data/docker-gitlab-158/data"
mkdir -p $config
mkdir -p $logs
mkdir -p $data

host="192.168.2.158"
http_port="7080"
https_port="7443"
addr=$host:$http_port
ssh_port="2222"
docker run -d \
-h $addr \
-p $http_port:$http_port \
-p $https_port:$https_port \
-p $ssh_port:22 \
-e TZ=Asia/Shanghai \
--shm-size 256m \
--name gitlab \
--restart always \
--privileged=true \
-v $config:/etc/gitlab \
-v $logs:/var/log/gitlab \
-v $data:/var/opt/gitlab \
gitlab/gitlab-ce:latest

# 查看密码, 账号默认是root
cat $config/initial_root_password

# vi $config/gitlab.rb

cat >> $config/gitlab.rb <<EOF
external_url 'http://$host:$http_port/'
gitlab_rails['gitlab_shell_ssh_port'] = $ssh_port
# 禁用 puma cluster 模式， 可以减少 100-400 MB占用
puma['worker_processes'] = 0

# Sidekiq 是一个后台处理守护进程。默认情况下使用 GitLab 配置时，它以50. 这确实会影响它在给定时间可以分配多少内存。建议将其配置为使用明显更小的值5或10（首选）。
sidekiq['max_concurrency'] = 10

# GitLab 默认启用所有服务，无需任何额外配置即可提供完整的 DevOps 解决方案。一些默认服务，如监控，对于 GitLab 的运行不是必需的，可以禁用以节省内存。
# 禁用监控
prometheus_monitoring['enable'] = false

# GitLab 由许多组件（用 Ruby 和 Go 编写）组成，其中 GitLab Rails 是最大的组件，并且消耗最多的内存。
gitlab_rails['env'] = {
  'MALLOC_CONF' => 'dirty_decay_ms:1000,muzzy_decay_ms:1000'
}
EOF

docker restart gitlab
#docker exec -it gitlab editor /etc/gitlab/gitlab.rb

set +x
