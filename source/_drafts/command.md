---
title: CentOS 命令大杂烩
tags:
  - CentOS
  - command
---

# 防火墙

## 开启端口

```bash
# --permanent 永久生效，没有此参数重启后失效
# --zone 作用域
# --add-port=8080-8081/tcp 添加端口，格式为：端口/通讯协议
$ firewall-cmd --permanent --zone=public --add-port=8080-8081/tcp
```

## 重新加载

```bash
$ firewall-cmd --reload
```
