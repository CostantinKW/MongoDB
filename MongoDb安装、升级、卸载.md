### 安装mongodb

```
#!/bin/bash
# chkconfig: - 85 15

#set_proxy
#sudo apt-key adv --keyserver-options http-proxy=http://172.16.10.2:8118 --keyserver keyserver.ubuntu.com --recv 9DA31620334BD75D9DCB49F368818C72E52529D4

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4

echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list

sudo apt-get update

sudo apt-get install -y mongodb-org=4.0.2 mongodb-org-server=4.0.2 mongodb-org-shell=4.0.2 mongodb-org-mongos=4.0.2 mongodb-org-tools=4.0.2

#unset_proxy
```

- 启动单机版mongo实例

```
sudo service mongod start
```

- 设置mongo开机启动

```
systemctl enable mongod.service      #将mongo服务设置为自启动
systemctl is-enabled mongod.service  #检查服务是否自启动
```

- 卸载mongo

- 停止mongodb  
  
    ```
    sudo service mongod stop
    ```
    
    
    
- 删除软件包  
  
    ```
    sudo apt-get purge mongodb-org
    ```
    
    
    
- 删除数据目录

```
sudo rm -r /var/log/mongodb  
sudo rm -r /var/lib/mongodb

```

- 安装中遇到的问题

- 安装后使用 sudo service mongodb start 命令报错 `Failed to start mongod.service: Unit mongod.service not found.`  
    _V2.6以后的版本mongo服务名称为service mongod_  
    _这是由于缺少配置文件mongodb.service_
    
- [解决方案](https://www.cnblogs.com/alan2kat/p/7771635.html)：
  
    - 创建配置文件

```
vim /etc/systemd/system/mongodb.service
```

- 写入文本

```
[Unit]
Description=MongoDB Database Service
Wants=network.target
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/mongod --config /etc/mongod.conf
Restart=always
StandardOutput=syslog
StandardError=syslog

[Install]
WantedBy=multi-user.target
```

- 再次启动mongodb

```
systemctl daemon-reload
systemctl enable mongod.service
service mongod start
```

- error- Failed to start mongodb.service: Unit mongodb.service is masked.

```
sudo systemctl unmask mongodb
```