#!/bin/bash

# Copyright 2014 The Kubernetes Authors All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


DOCKER_OPTS=${1:-""}

DOCKER_CONFIG=/opt/kubernetes/cfg/docker

cat <<EOF >$DOCKER_CONFIG
DOCKER_OPTS="-H tcp://127.0.0.1:2376 -H unix:///var/run/docker.sock -s devicemapper --selinux-enabled=false ${DOCKER_OPTS}"
EOF

cat <<EOF >/usr/lib/systemd/system/docker.service
[Unit]
Description=Docker Application Container Engine
Documentation=http://docs.docker.com
After=network.target flannel.service
Requires=flannel.service

[Service]
Type=notify
EnvironmentFile=-/run/flannel/docker
EnvironmentFile=-/opt/kubernetes/cfg/docker
WorkingDirectory=/opt/kubernetes/bin
ExecStart=/usr/bin/dockerd \$DOCKER_OPT_BIP \$DOCKER_OPT_MTU \$DOCKER_OPTS
ExecReload=/bin/kill -s HUP $MAINPID
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
Delegate=yes
# kill only the docker process, not all processes in the cgroup
KillMode=process

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable docker
systemctl restart docker
