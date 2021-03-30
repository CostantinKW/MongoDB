#!/bin/bash
# chkconfig: - 85 15

name=mongod
path_bin=/usr/bin/

ulimit -f unlimited
ulimit -t unlimited
ulimit -v unlimited
ulimit -l unlimited
ulimit -n 64000
ulimit -m unlimited
ulimit -u 64000

ip1=192.168.0.78
ip2=192.168.0.119

mongos --bind_ip 0.0.0.0 --port 27010 --configdb cfgset/${ip1}:27011,${ip2}:27011 --logpath /data/mongo/mongos/log/mongos.log --fork
if [ $? -eq 0 ];then
  echo "`date '+%Y-%m-%d %H:%M:%S'`: mongos start success" >> /data/mongo/auto_start_log/auto_start.log
else
  echo "`date '+%Y-%m-%d %H:%M:%S'`: mongos start failed" >> /data/mongo/auto_start_log/auto_start.log
fi
