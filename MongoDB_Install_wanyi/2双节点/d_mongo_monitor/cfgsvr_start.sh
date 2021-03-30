#!/bin/bash
# chkconfig: - 85 15

ulimit -f unlimited
ulimit -t unlimited
ulimit -v unlimited
ulimit -l unlimited
ulimit -n 64000
ulimit -m unlimited
ulimit -u 64000

rm -rf /data/mongo/auto_start_log/
mkdir -p /data/mongo/auto_start_log/
touch /data/mongo/auto_start_log/auto_start.log


CacheSizeGB=10

mongod --configsvr --dbpath /data/mongo/mongo_cfgsvr/data --logpath /data/mongo/mongo_cfgsvr/log/cfg.log --bind_ip 0.0.0.0 --port 27011 --replSet cfgset --fork
if [ $? -eq 0 ];then
  echo "`date '+%Y-%m-%d %H:%M:%S'`: cfgsvr start success" >> /data/mongo/auto_start_log/auto_start.log
else
  echo "`date '+%Y-%m-%d %H:%M:%S'`: cfgsvr start failed" >> /data/mongo/auto_start_log/auto_start.log
fi