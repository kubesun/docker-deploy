#!/bin/bash

set -x
img_name="runner4"
config="/mnt/data/gitlab-runner/${img_name}/config"
rm -rf $config
set +x
