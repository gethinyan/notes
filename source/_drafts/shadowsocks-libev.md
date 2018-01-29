---
title: CentOS 安装 Shadowsocks-libev
tags:
  - Shadowsocks
  - Shadowsocks-libev
  - CentOS
category:
  - Shadowsocks
date: 2018-01-29 23:32:14
---


# 安装 EPEL 源

1. 什么是企业版 Linux 附加软件包（EPEL）？
- 企业版 Linux 附加软件包（以下简称 EPEL）是一个 Fedora 特别兴趣小组，用以创建、维护以及管理针对企业版 Linux 的一个高质量附加软件包集，面向的对象包括但不限于 红帽企业版 Linux (RHEL)、CentOS、Scientific Linux (SL)、Oracle Linux (OL) 。

- EPEL 的软件包通常不会与企业版 Linux 官方源中的软件包发生冲突，或者互相替换文件。EPEL 项目与 Fedora 基本一致，包含完整的构建系统、升级管理器、镜像管理器等等。

2. 通过 yum 命令安装 EPEL

```bash
$ yum install epel-release -y
```

# 安装依赖

1. 更新 CentOS 系统

```bash
$ yum update -y
```

2. 安装 Shadowsocks-libev 依赖

```bash
$ yum install gcc gettext autoconf libtool automake make pcre-devel asciidoc xmlto c-ares-devel libev-devel libsodium-devel mbedtls-devel -y
```

# 安装 Shadowsocks-libev

> 第一次安装 Shadowsocks-libev 的时候是通过 yum 源安装的，不过现在找不到 Shadowsocks-libev 的 yum 源，暂时通过 github 下载源码并配置好 Shadowsocks-libev

```bash
# 创建 work 用户并修改密码
$ useradd work
$ passwd work
$ su work && cd ~
# 创建 source 文件夹用于存放源码
$ mkdir source
# 从 github 上下载源码
$ git clone https://github.com/shadowsocks/shadowsocks-libev.git
$ cd shadowsocks-libev
# 开启 Shadowsocks-libev，更多参数通过 ss-server --help 查看
$ /home/work/source/shadowsocks-libev/bin/ss-server -s 0.0.0.0 -p port -k password -m method -u &
# 也可以用 nohup 启动 Shadowsocks-libev
$ nohup /home/gethin/local/shadowsocks-libev/bin/ss-server -c /home/gethin/local/shadowsocks-libev/etc/shadowsocks-libev.json < /dev/null >> /home/gethin/local/shadowsocks-libev/logs/shadowsocks-libev.log 2>&1 &
```
