# MongoDB数据导入导出操作

## 导出操作

- 示例：

  ```shell
mongoexport -h 127.0.0.1:27010 -d idi_xddq -c datas  -o /root/backup/datas.json  --query '{"code": {"$exists": true},"timestamp": { "$gt": ISODate("2019-12-29T00:00:00Z"), "$lt": ISODate("2019-12-29T06:00:00Z")} }'
  ```
  
  导出 127.0.0.1: 27010 idi_xddq.datas符合 `{"code": {"$exists": true},"timestamp": { "$gt": ISODate("2019-12-29T00:00:00Z"), "$lt": ISODate("2019-12-29T06:00:00Z")} }`  条件的数据至   /root/backup/datas.json  文件。

## 导入操作

- 示例：

  ```shell
mongoimport -h 192.168.250.240:27010 -d idi_node09 -c datas   /root/backup/datas.json
  ```

  将  /root/backup/datas.json  文件内的数据导入到  192.168.250.240:27010 idi_09.datas
  
  

