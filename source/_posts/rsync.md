---
title: rsync 实现文件同步
tags:
  - rsync
  - sersync
  - nfs
  - CentOS
date: 2019-01-02 17:44:12
---



# 实现目标

> 启用备用机开启负载均衡，同步主服务器的代码、静态资源到备用机让备用机跑起来。

## 从服务器

1. 安装 `rsync`

```bash
# 查看是否安装rsync
$ rpm -qa | grep rsync
# 安装rsync
$ yum install rsync -y
```

2. 配置文件 `/etc/rsyncd.conf`，可以配置 `hosts allow` 这样我们可以只接受允许的 `ip` 的同步请求

```bash
uid = root
gid = root
# 最大连接数
max connections = 4
# 默认为true，修改为no，增加对目录文件软连接的备份
use chroot = no
# 允许进行数据同步的客户端IP地址，可以设置多个，用英文状态下逗号隔开
# hosts allow = 47.52.175.26
# 定义日志存放位置
log file = /var/log/rsyncd.log
# 忽略无关错误
ignore errors = yes
# 设置rsync服务端文件为读写权限
read only = no
# 认证的用户名与系统帐户无关在认证文件做配置，如果没有这行则表明是匿名
auth users = rsync
# 密码认证文件，格式(虚拟用户名:密码）
secrets file = /etc/rsync.pass
# 这里是认证的模块名，在client端需要指定，可以设置多个模块和路径
[webroot]
# 自定义注释
comment = webroot
# 文件存放的路径
path = /home/work/orp/webroot

[static]
comment = static
path = /home/work/orp/static
```

3. 密码文件

```bash
$ echo test:test > /etc/rsync.pass
# 需要注意的是必须把密码文件的权限设为600，否则会报错
$ chmod 600 /etc/rsync.pass
```

4. 运行 `rsync`

```bash
# 因为rsync默认监听的是873端口，需要用root权限运行
$ rsync --daemon
```

## 主服务器

1. 安装 `rsync`

```bash
# 查看是否安装rsync
$ rpm -qa | grep rsync
# 安装rsync
$ yum install rsync -y
```

2. 解压 `sersync`

```bash
# 为了方便，已经下好了sersync的安装包，只需解压并移到自己想要的地方即可
$ cd ~ && tar -zxvf sersync2.5.4_64bit_binary_stable_final.tar.gz
$ mv GNU-Linux-x86 sersync
$ rm sersync2.5.4_64bit_binary_stable_final.tar.gz
```

3. 配置 `sersync`

```bash
# 创建不同的目录区分文件类型，然后创建一个密码文件内容为从服务器的rsync密码，每个模块的xml文件已经写好只需要拷贝到conf文件夹即可，
$ cd /root/sersync && mkdir bin conf etc logs
$ mv sersync2 bin
$ mv confxml.xml conf
$ echo 'test' > etc/user.pass
$ chmod 600 etc/user.pass
```

4. 配置文件 `*.xml`

  - 可以设置过滤文件夹(文件)，设置了之后就不会同步该文件夹(文件)，需要注意的是在设置了过滤后启动 `sersync` 时 `-r` 参数会失效

```xml
<filter start="true">
    <exclude expression="^upload/*"></exclude>
</filter>s
```

  - 可以修改监听的本地目录及远程的 `ip` 和 `module_name`，如果需要同步到多台从服务器，配置多个 `remote` 即可，还支持过滤，但是在设置了过滤后启动 `sersync` 时 `-r` 参数会失效

```xml
<localpath watch="/home/work/orp/static/">
	<remote ip="0.0.0.0" name="static"/>
</localpath>
```

  - 可以修改失败重传的时间间隔，根据实际需求修改 `timeToExecute` 属性

```xml
<failLog path="/tmp/rsync_fail_log.sh" timeToExecute="60"/><!-- default every 60mins execute once -->
```

5. 运行 `sersync`

```bash
# webroot模块
$ /root/sersync/bin/sersync2 -r -d -o /root/sersync/conf/webroot.xml > /root/sersync/logs/webroot.log 2>&1 &
# static模块
$ /root/sersync/bin/sersync2 -r -d -o /root/sersync/conf/static.xml > /root/sersync/logs/static.log 2>&1 &
```

6. 由于运行 `sersync` 时每个 `webroot` 模块都有指定 `filter` 过滤条件，虽然加上了 `-r` 参数，但是并不会进行第一次同步，所以需要我们针对每个模块手动的运行一次 `sersync` 命令同步一次

```bash
# webroot模块
$ root/sersync/bin/sersync2 -r -o /root/sersync/conf/webroot_full.xml
```

## 问题

1. 因为线上有部分图片使用了百度对象存储提供的缩略服务，即在url后加上 `@w_*`，但是使用缩略服务有一个要求就是对象存储上必须有原图，当我们没有访问 `cdn` 没有回源的时候对象存储上是没有原图的，所以我们需要手动的访问一次，既然 `sersync` 可以监听文件的变化，能不能在我们上传了图片后用 `curl` 访问一次呢？

  - `sersync` 开启 `command` 插件

```xml
<sersync>
    <plugin start="true" name="command"/>
</sersync>
<plugin name="command">
    <param prefix="/root/sersync/bin/curl.sh" suffix="" ignoreError="true"/><!--prefix /opt/tongbu/mmm.sh suffix-->
</plugin>
```

  - `curl.sh`

```bash
#!/bin/bash

IMAGE_EXTENSIONS=('gif' 'jpg' 'png' 'jpeg' 'bmp' 'ico' 'svg');

sign=0;
absolute_path=$1;
file_src=${absolute_path#*//};
extension_name=${absolute_path##*.};
lowwer_extension_name=$(echo $extension_name | tr '[A-Z]' '[a-z]');

for extension in ${IMAGE_EXTENSIONS[*]}; do
  if [ $extension = $lowwer_extension_name ]; then
    sign=1
  fi;
done;

if [ $sign = 1 ]; then
  curl 'your cdn domain/upload/'$file_src > /dev/null;
  echo 'your cdn domain/upload/'$file_src >> /root/sersync/logs/curl.log;
fi;
```

  - 需要把 `curl.sh` 加上可执行的权限

```bash
$ chmod +x /root/sersync/bin/curl.sh
```

  - 仅开启 `sersync` 的 `command` 插件监听 `upload` 目录，配置文件 `static_upload.xml`

```xml
<sersync>
    <localpath watch="/home/work/orp/static/upload/">
    </localpath>
    <plugin start="true" name="command"/>
</sersync>
<plugin name="command">
    <param prefix="/root/sersync/bin/curl.sh" suffix="" ignoreError="true"/><!--prefix /opt/tongbu/mmm.sh suffix-->
    <filter start="false">
        <include expression="(.*)\.php"/>
        <include expression="(.*)\.sh"/>
    </filter>
</plugin>
```

```bash
/root/sersync/bin/sersync2 -d -o /root/sersync/conf/static_upload.xml -m command
```

2. 当开启负载均衡的时候，用户上传文件调用接口分发到了备用机时，文件只存在于备用机，因为不是双向同步，这时主服务器上没有该文件，所以访问该文件时负载均衡分发到主服务器会报404

  - `nfs` 工作流程

```bash
1. 由程序在NFS客户端发起存取文件的请求，客户端本地的RPC(rpcbind)服务会通过网络向NFS服务端的RPC的111端口发出文件存取功能的请求。
2. NFS服务端的RPC找到对应已注册的NFS端口，通知客户端RPC服务。
3. 客户端获取正确的端口，并与NFS daemon联机存取数据。
4. 存取数据成功后，返回前端访问程序，完成一次存取操作。
```

  - 主服务器安装 `nfs`

```bash
# 查看系统是否已安装nfs
$ rpm -qa | grep nfs
$ rpm -qa | grep rpcbind
# 安装nfs
$ yum install nfs-utils rpcbind -y
```

  - 主服务器配置文件 `/etc/exports`

```
/home/work/orp/static/upload 172.16.0.0/16(rw,no_root_squash,sync,no_subtree_check)
```

  - 重要配置文件参数说明

```bash
ro：共享目录只读
rw：共享目录可读可写
all_squash：所有访问用户都映射为匿名用户或用户组
no_all_squash（默认）：访问用户先与本机用户匹配，匹配失败后再映射为匿名用户或用户组
root_squash（默认）：将来访的root用户映射为匿名用户或用户组
no_root_squash：来访的root用户保持root帐号权限
anonuid=<UID>：指定匿名访问用户的本地用户UID，默认为nfsnobody（65534）
anongid=<GID>：指定匿名访问用户的本地用户组GID，默认为nfsnobody（65534）
secure（默认）：限制客户端只能从小于1024的tcp/ip端口连接服务器
insecure：允许客户端从大于1024的tcp/ip端口连接服务器
sync：将数据同步写入内存缓冲区与磁盘中，效率低，但可以保证数据的一致性
async：将数据先保存在内存缓冲区中，必要时才写入磁盘
wdelay（默认）：检查是否有相关的写操作，如果有则将这些写操作一起执行，这样可以提高效率
no_wdelay：若有写操作则立即执行，应与sync配合使用
subtree_check（默认） ：若输出目录是一个子目录，则nfs服务器将检查其父目录的权限
no_subtree_check ：即使输出目录是一个子目录，nfs服务器也不检查其父目录的权限，这样可以提高效率
```

  - 主服务器启动 `nfs`，`rpcbind` 服务

```bash
$ service rpcbind start
$ service nfs start
```

  - 备用机安装 `nfs`

```bash
# 查看系统是否已安装nfs
$ rpm -qa | grep nfs
$ rpm -qa | grep rpcbind
# 安装nfs
$ yum install nfs-utils rpcbind -y
```

  - 备用机查看 `nfs` 共享目录

```bash
$ showmount -e 172.16.0.2
Export list for 172.16.0.2:
/home/work/orp/static/upload 172.16.0.0/16
```

  - 挂载`nfs`

```bash
mount 172.16.0.2:/home/work/orp/static/upload /home/work/orp/static/upload
```

> 这里需要注意一点，在挂载之后对应的docker需要重启一次
