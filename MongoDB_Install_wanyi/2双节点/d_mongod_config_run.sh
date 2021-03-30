#!/bin/bash
# chkconfig: - 85 15


# 设置swap，提高mongo性能
echo "vm.swappiness = 1" >> /etc/sysctl.conf
sudo sysctl -p

# Disable Transparent Huge Pages
sudo systemctl daemon-reload
sudo systemctl start disable-transparent-huge-pages
sudo systemctl enable disable-transparent-huge-pages


# 新建目录
mkdir -p  /data/mongo/{mongos,mongo_cfgsvr,mongo_shard1,mongo_shard2}/log/
mkdir -p  /data/mongo/{mongo_cfgsvr,mongo_shard1,mongo_shard2}/data/

# 启动mongod实例
mongod --configsvr --dbpath /data/mongo/mongo_cfgsvr/data --logpath /data/mongo/mongo_cfgsvr/log/cfg.log --bind_ip 0.0.0.0 --port 27011 --replSet cfgset --fork ; 

# mongod(cfgsvr/shard)副本集启动与配置 
ulimit -f unlimited
ulimit -t unlimited
ulimit -v unlimited
ulimit -l unlimited
ulimit -n 64000
ulimit -m unlimited
ulimit -u 64000

CacheSizeGB=10

mongod --configsvr --dbpath /data/mongo/mongo_cfgsvr/data --logpath /data/mongo/mongo_cfgsvr/log/cfg.log --bind_ip 0.0.0.0 --port 27011 --replSet cfgset --fork
mongod --shardsvr --bind_ip 0.0.0.0 --port 27001 --replSet shard1 --dbpath /data/mongo/mongo_shard1/data --logpath /data/mongo/mongo_shard1/log/shard1.log --wiredTigerCacheSizeGB=${CacheSizeGB} --fork
mongod --shardsvr --bind_ip 0.0.0.0 --port 27002 --replSet shard2 --dbpath /data/mongo/mongo_shard2/data --logpath /data/mongo/mongo_shard2/log/shard2.log --wiredTigerCacheSizeGB=${CacheSizeGB} --fork
