#!/bin/bash
# chkconfig: - 85 15


# rabbitmq节点（仲裁节点）设置shard1和shard2
mkdir -p  /data/mongo/{mongo_shard1,mongo_shard2}/log/
mkdir -p  /data/mongo/{mongo_shard1,mongo_shard2}/data/


ulimit -f unlimited
ulimit -t unlimited
ulimit -v unlimited
ulimit -l unlimited
ulimit -n 64000
ulimit -m unlimited
ulimit -u 64000

CacheSizeGB=5

mongod --shardsvr --bind_ip 0.0.0.0 --port 27001 --replSet shard1 --dbpath /data/mongo/mongo_shard1/data --logpath /data/mongo/mongo_shard1/log/shard1.log --wiredTigerCacheSizeGB=${CacheSizeGB} --fork
mongod --shardsvr --bind_ip 0.0.0.0 --port 27002 --replSet shard2 --dbpath /data/mongo/mongo_shard2/data --logpath /data/mongo/mongo_shard2/log/shard2.log --wiredTigerCacheSizeGB=${CacheSizeGB} --fork
