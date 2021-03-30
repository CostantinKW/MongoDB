假定三台虚拟机分别为：【MongoDB1：ip1】【MongoDB2：ip2】【MongoDB3：ip3】
1.MongoDB1、MongoDB2、MongoDB3执行m_mongo_install.sh脚本，安装MongoDB
2.MongoDB1、MongoDB2、MongoDB3上传disable-transparent-huge-pages.service到/etc/systemd/system/
或者直接编辑/etc/systemd/system/disable-transparent-huge-pages.service，填写指定内容
3.MongoDB1、MongoDB2、MongoDB3执行t_mongo_config_run.sh脚本进行配置启动
4.配置MongoDB1
###设置主备节点
mongo --port 27011 
rs.initiate({_id:'cfgset',members:[{_id:1,host:'【ip1】:27011'}]})
rs.add("【ip2】:27011")
rs.add("【ip3】:27011")
###设置分片shard1和仲裁节点
mongo --port 27001 
rs.initiate({_id:'shard1',members:[{_id:1,host:'【ip1】:27001'}]})
rs.add("【ip2】:27001")
rs.addArb("【ip3】:27001")
5.配置MongoDB2
###设置分片shard2和仲裁节点
mongo --port 27002  
rs.initiate({_id:'shard2',members:[{_id:1,host:'【ip2】:27002'}]})
rs.add("【ip3】:27002")
rs.addArb("【ip1】:27002")
6.配置MongoDB3
###设置分片shard3和仲裁节点
mongo --port 27003
rs.initiate({_id:'shard3',members:[{_id:1,host:'【ip3】:27003'}]})
rs.add("【ip1】:27003")
rs.addArb("【ip2】:27003")
7.修改t_mongos_start.sh脚本中的ip信息，在MongoDB1、MongoDB2、MongoDB3上执行
8.设置分片副本集
## 在任一节点mongos上设置分片（串联mongos与分片副本集）
mongo --port 27010
use admin  
db.runCommand( { addshard : "shard1/【ip1】:27001,【ip2】:27001,【ip3】:27001", name:"data_set1" } )
db.runCommand( { addshard : "shard2/【ip2】:27002,【ip1】:27002,【ip3】:27002", name:"data_set2" } )
db.runCommand( { addshard : "shard3/【ip3】:27003,【ip1】:27003,【ip3】:27003", name:"data_set3" } )
9.MongoDB1上设置副本优先级，执行
mongo --port 27001
config=rs.conf()
config.members[【根据自身IP确认索引】].priority = 3
rs.reconfig(config)
10.MongoDB2上设置副本优先级，执行
mongo --port 27002
config=rs.conf()
config.members[【根据自身IP确认索引】].priority = 3
rs.reconfig(config)
11.MongoDB3上设置副本优先级，执行
mongo --port 27003
config=rs.conf()
config.members[【根据自身IP确认索引】].priority = 3
rs.reconfig(config)
12.上传start_mongod.sh、start_mongos.sh（修改IP）到MongoDB1、MongoDB2、MongoDB3的/root/mongo_script/目录下
修改/etc/rc.local文件，增加自启动功能
/root/mongo_script/start_mongod.sh
sleep 5
/root/mongo_script/start_mongos.sh
exit 0
13.上传t_mongo_monitor文件夹中的文件到MongoDB1，MongoDB2，MongoDB3的/root/mongo_script/目录下，执行
crontab -e 
*/5 * * * * python3 /root/mongo_script/check_mongo_service.py