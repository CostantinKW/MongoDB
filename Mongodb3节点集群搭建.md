sudo systemctl enable disable-transparent-huge-pages



# Mongodb123三节点安装手册

## IP、端口(三节点)

| 192.168.20.165（ssh mongo_1） | 192.168.20.138 (ssh mongo_2) | 192.168.20.137 (ssh mongo_3) |
| :---------------------------: | :--------------------------: | :--------------------------: |
|         mongos: 27010         |        mongos: 27010         |        mongos: 27010         |
|         cfgsvr: 27011         |        cfgsvr: 27011         |        cfgsvr: 27011         |
|       shard1(主)：27001       |      shard1(备)：27001       |     shard1 (仲裁)：27001     |
|     shard2 (仲裁)：27002      |      shadr2(主)： 27002      |     shard2 (备) ：27002      |
|      shard3 (备) ：27003      |     shard3 (仲裁)：27003     |      shard3(主) ：27003      |

## 设置swap (三台虚拟机都需要执行)

```shell
echo "vm.swappiness = 1" >> /etc/sysctl.conf
sudo sysctl -p
```



## Disable Transparent Huge Pages (THP) (三台虚拟机都需要执行)

```shell
vim  /etc/systemd/system/disable-transparent-huge-pages.service
```

写入：

```shell
[Unit]
Description=Disable Transparent Huge Pages (THP)
DefaultDependencies=no
After=sysinit.target local-fs.target
Before=mongod.service

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'echo never | tee /sys/kernel/mm/transparent_hugepage/enabled > /dev/null'

[Install]
WantedBy=basic.target
```

依次执行下述步骤，若报错，检查上一步写入的内容是否有错:

```shell
sudo systemctl daemon-reload

sudo systemctl start disable-transparent-huge-pages

sudo systemctl enable disable-transparent-huge-pages
```

## 安装mongodb (三个虚拟机都需要安装)

```shell
#!/bin/bash

chkconfig: - 85 15

apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4

echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.0.list

apt-get update

apt-get install -y mongodb-org=4.0.2 mongodb-org-server=4.0.2 mongodb-org-shell=4.0.2 mongodb-org-mongos=4.0.2 mongodb-org-tools=4.0.2
```

这一段可封装为脚本。

## 配置和启动 1 (三个虚拟机都执行)

```shell
mkdir -p  /data/mongo/{mongos,mongo_cfgsvr,mongo_shard1,mongo_shard2,mongo_shard3}/log/
mkdir -p  /data/mongo/{mongo_cfgsvr,mongo_shard1,mongo_shard2,mongo_shard3}/data/

#启动mongod实例

mongod --configsvr --dbpath /data/mongo/mongo_cfgsvr/data --logpath /data/mongo/mongo_cfgsvr/log/cfg.log --bind_ip 0.0.0.0 --port 27011 --replSet cfgset --fork ; 



#mongod(cfgsvr/shard)副本集启动与配置 

#!/bin/bash

#chkconfig: - 85 15

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
mongod --shardsvr --bind_ip 0.0.0.0 --port 27003 --replSet shard3 --dbpath /data/mongo/mongo_shard3/data --logpath /data/mongo/mongo_shard3/log/shard3.log --wiredTigerCacheSizeGB=${CacheSizeGB} --fork
```

这一段可封装为脚本，三台虚拟机执行同样的代码操作。

CacheSizeGB=10是一个经验值，计算方式为：总的机器内存 / (分片进程数 + 路由进程)

***确定shard、mongos数量***
***使用Sharded cluster时，部署shard、mongos的数量是由应用需求决定***
***使用sharding解决数据存储问题时，假设单个shard能存储M， 需要的存储总量是N，那么可以按照如下公式来计算实际需要的shard、mongos数量：***
***numberOfShards = N/M/0.75 （假设容量水位线为75%）***
***numberOfMongos = 2+（对访问要求不高，至少部署2个mongos做高可用即可）***
***使用sharding解决高并发写入（或读取）数据的问题，假设单个shard最大QPS为M，单个mongos最大QPS为Ms，需要总的QPS为Q。那么可以按照如下公式来计算实际需要的shard、mongos数量：***
***numberOfShards = Q/M/0.75 （假设负载水位线为75%）***
***numberOfMongos = Q/Ms/0.75***             

​                                                                                         ***-------------from 刘肖***

## 配置和启动 2  (三个虚拟机都执行)

### cfgsvr

```shell
#mongo1设置主备节点   只需要在mongo1上执行

mongo --port 27011 
rs.initiate({_id:'cfgset',members:[{_id:1,host:'192.168.10.2:27011'}]})  #mongo1的 ip
rs.add("192.168.10.3:27011")   #mongo2 的ip
rs.add("192.168.10.4:27011")   #mongo3 的ip
```

### shard1

```shell
#mongo1设置  此处的ip根据 ip\端口章节配置的来写
mongo --port 27001 
rs.initiate({_id:'shard1',members:[{_id:1,host:'192.168.10.2:27001'}]})  #shard1的主节点ip
rs.add("192.168.10.3:27001")   #shard1的备用节点ip
rs.addArb("192.168.10.4:27001")   #shard1的仲裁节点ip
```

### shard2

```shell
#mongo2设置
mongo --port 27002  
rs.initiate({_id:'shard2',members:[{_id:1,host:'192.168.10.3:27002'}]})  #shard2的主节点ip
rs.add("192.168.10.4:27002")   #shard2的备用节点ip
rs.addArb("192.168.10.2:27002")  #shard2的仲裁节点ip
```

### shard3

```shell
#mongo3设置
mongo --port 27003
rs.initiate({_id:'shard3',members:[{_id:1,host:'192.168.10.4:27003'}]})  #shard3的主节点ip
rs.add("192.168.10.2:27003")    #shard3的备用节点ip
rs.addArb("192.168.10.3:27003")   #shard3的仲裁节点ip
```

### mongos启动与配置

```shell
#!/bin/bash

#chkconfig: - 85 15

name=mongod
path_bin=/usr/bin/

ulimit -f unlimited
ulimit -t unlimited
ulimit -v unlimited
ulimit -l unlimited
ulimit -n 64000
ulimit -m unlimited
ulimit -u 64000

ip1=192.168.10.2   #此处的ip需要根据配置的三台虚拟机的ip来更新
ip2=192.168.10.3
ip3=192.168.10.4

mongos --bind_ip 0.0.0.0 --port 27010 --configdb cfgset/${ip1}:27011,${ip2}:27011,${ip3}:27011 --logpath /data/mongo/mongos/log/mongos.log --fork

#在任一节点mongos上设置分片（串联mongos与分片副本集),这一步在任意一台虚拟机上执行都可以

mongo --port 27010
use admin  
db.runCommand( { addshard : "shard1/192.168.10.2:27001,192.168.10.3:27001,192.168.10.4:27001", name:"data_set1" } )
db.runCommand( { addshard : "shard2/192.168.10.3:27002,192.168.10.2:27002,192.168.10.4:27002", name:"data_set2" } )
db.runCommand( { addshard : "shard3/192.168.10.3:27003,192.168.10.2:27003,192.168.10.4:27003", name:"data_set3" } )
```

## 更改副本集优先级设置

*在设置mongodb副本集时，Primary节点。second节点，仲裁节点，有可能资源配置（CPU或者内存）不均衡，所以要求某些节点不能成为Primary*
*我们知道mongodb的设置：*
  *除了仲裁节点，其它每一个节点都有个优先权，能够手动设置优先权来决定谁的成为primay的权重最大。*

  *副本集中通过设置priority的值来决定优先权的大小。这个值的范围是0--100，值越大，优先权越高。*
*默认的值是1，rs.conf是不显示的；*
*假设值是0，那么不能成为primay。*

配置过程：
通过改动priority的值来实现（默认的优先级是1（0-100）。priority的值设的越大，就优先成为主）

### MongoDB1上设置副本优先级

执行

```shell
mongo --port 27001
config=rs.conf()
config.members[【根据自身IP确认索引】].priority = 3
rs.reconfig(config)
```

### MongoDB2上设置副本优先级

执行

```shell
mongo --port 27002
config=rs.conf()
config.members[【根据自身IP确认索引】].priority = 3
rs.reconfig(config)
```



### MongoDB3上设置副本优先级

执行

```shell
mongo --port 27003
config=rs.conf()
config.members[【根据自身IP确认索引】].priority = 3
rs.reconfig(config)
```

### 根据自身IP确认索引

执行 rs.conf()之后，展示的信息：

```json

	"members" : [
		{
			"_id" : 1,
			"host" : "192.168.20.138:27002",
			"arbiterOnly" : false,
			"buildIndexes" : true,
			"hidden" : false,
			"priority" : 1,
			"tags" : {
				

		},
		"slaveDelay" : NumberLong(0),
		"votes" : 1
	},
	{
		"_id" : 2,
		"host" : "192.168.20.137:27002",
		"arbiterOnly" : false,
		"buildIndexes" : true,
		"hidden" : false,
		"priority" : 1,
		"tags" : {
			
		},
		"slaveDelay" : NumberLong(0),
		"votes" : 1
	},
	{
		"_id" : 3,
		"host" : "192.168.20.165:27002",
		"arbiterOnly" : true,
		"buildIndexes" : true,
		"hidden" : false,
		"priority" : 0,
		"tags" : {
			
		},
		"slaveDelay" : NumberLong(0),
		"votes" : 1
	}
]
```

例如mongo2执行rs.conf()之后，由于mongo2的ip是 192.168.20.138，端口是 27002，根据ip端口可以看出，mongo2对应的是members列表中的第一个，所以设置优先级的时候就是： config.members[ 0 ].priority = 3

## 增加自启动功能

修改/etc/rc.local文件，增加自启动功能

```shell
/root/mongo_script/start_mongod.sh
sleep 5
/root/mongo_script/start_mongos.sh
exit 0
```

## 监控mongo进程是否运行

```shell
crontab -e 
*/5 * * * * python3 /root/mongo_script/check_mongo_service.py
```

这一步需要参考MongoDB_Install中三节点的安装步骤