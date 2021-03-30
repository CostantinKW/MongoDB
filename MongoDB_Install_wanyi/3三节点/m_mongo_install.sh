#!/bin/bash
# chkconfig: - 85 15

version=4.0.2


#set_proxy
#sudo apt-key adv --keyserver-options http-proxy=http://172.16.10.2:8118 --keyserver keyserver.ubuntu.com --recv 9DA31620334BD75D9DCB49F368818C72E52529D4

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4

echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list

sudo apt-get update

sudo apt-get install -y libcurl3

sudo apt-get install -y mongodb-org=${version} mongodb-org-server=${version} mongodb-org-shell=${version} mongodb-org-mongos=${version} mongodb-org-tools=${version}


#unset_proxy