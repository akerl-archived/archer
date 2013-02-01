#!/bin/bash

# ansible all -m script -a scripts/bootstrap.sh

mkdir -p /root/.ssh
curl -s 'https://raw.github.com/akerl/keys/master/ender.pub' > /root/.ssh/authorized_keys

