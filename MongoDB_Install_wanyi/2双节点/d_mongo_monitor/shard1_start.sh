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


CacheSizeGB=10

mongod --shardsvr --bind_ip 0.0.0.0 --port 27001 --replSet shard1 --dbpath /data/mongo/mongo_shard1/data --logpath /data/mongo/mongo_shard1/log/shard1.log --wiredTigerCacheSizeGB=${CacheSizeGB} --setParameter maxIndexBuildMemoryUsageMegabytes=100 --fork
if [ $? -eq 0 ];then
  echo "`date '+%Y-%m-%d %H:%M:%S'`: shard1 start success" >> /data/mongo/auto_start_log/auto_start.log
else
  echo "`date '+%Y-%m-%d %H:%M:%S'`: shard1 start failed" >> /data/mongo/auto_start_log/auto_start.log
fi

