---
title: 和我一起走近 git
tags:
  - git
  - GitHub
date: 2019-01-18 16:07:57
---


# `git` 设置

```bash
# 配置用户名和邮箱
$ git config --global user.name "gethin"
$ git config --global user.email "gethin.yan@gmail.com"
# Unix/Mac 用户
$ git config --global core.autocrlf input
$ git config --global core.safecrlf true
# Windows 用户
$ git config --global core.autocrlf true
$ git config --global core.safecrlf true
```

# 关于 `CRLF` 和 `LF`

`Linux/Mac OS` 以 `LF(\n)` 结尾，而 `Windows` 以 `CRLF(\r\n)` 结尾

```bash
# 提交时转换为 LF，检出时转换为 CRLF
$ git config --global core.autocrlf true
# 提交时转换为 LF，检出时不转换
$ git config --global core.autocrlf input
# 提交检出均不转换
$ git config --global core.autocrlf false
```

safecrlf 选项是针对提交时的配置，当有混用的情况发生的时候 git 应该给出的一些表现

```bash
# 拒绝提交包含混合换行符的文件
git config --global core.safecrlf true
# 允许提交包含混合换行符的文件
git config --global core.safecrlf false
# 提交包含混合换行符的文件时给出警告
git config --global core.safecrlf warn
```

<!-- more -->

# 别名

添加下列内容到你的 `$HOME` 目录的 `.gitconfig` 文件中

```
[alias]
  co = checkout
  ci = commit
  st = status
  br = branch
  hist = log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short
  type = cat-file -t
  dump = cat-file -p
```

# GitHub SSH Keys

使用SSH协议，您可以连接和验证远程服务器和服务。 使用SSH密钥，您可以连接到GitHub，而无需在每次访问时提供用户名或密码

## `ssh-keygen` 生成秘钥

`ssh-keygen` 命令用于为 `ssh` 生成、管理和转换认证秘钥，它支持 `RSA` 和 `DSA` 两种认证秘钥，秘钥文件放在 `~/.ssh` 文件夹中(~是用户根目录)，运行下面命令生成秘钥，密码为空(只需要按回车)

```bash
# -t 指定类型，-C 添加注释
$ ssh-keygen -t rsa -C "gethin.yan@gmail.com"
```

## 公钥放到 `GitHub`

生成秘钥之后进入 `~/.ssh` 文件夹下，复制 `id_rsa.pub` 文件的所有内容

```bash
打开 GitHub -> settings -> SSH and GPG keys -> New SSH key -> 将复制的内容添加进去
```

## 测试是否设置成功

```bash
$ ssh git@github.com
PTY allocation request failed on channel 0
Hi gethinyan! You've successfully authenticated, but GitHub does not provide shell access.
Connection to github.com closed.
```

# `git` 基础概念

 - `workspace` （工作区）
 - `stage` （暂存区）
 - `repository` （本地仓库）
 - `remote` （远程仓库）

# `git` 基本命令

因为习惯使用 git 图形化工具，所以很多时候使用 git 命令的时候需要去查，此处记录常用的基本命令方便随时查看

## 创建仓库

```bash
$ git init
```

## 检出仓库

```bash
$ git clone [local repository | remote]
```

## 添加文件到暂存区

```bash
$ git add [filename | . | -A | *]
```

## 查看工作目录状态

```bash
$ git stauts
```

### 比较差异

```bash
$ git diff [filename]
```

## 提交到仓库

```bash
# 这里 -am 不支持新建文件
$ git commit [-m | -am]
```

## 撤销修改

```bash
# 添加到暂存区的修改
$ git reset HEAD filename
# 未添加到暂存区的修改
$ git checkout -- filename
```

## 删除文件

```bash
$ git rm filename
```

## 移动文件

```bash
$ git mv filename path
```

## 分支

```bash
$ git branch [-a | -r | -d | -D ]
```

## 切换分支

```bash
$ git checkout [-b] branch
```

## 合并分支

```bash
$ git merge branch
$ git rebase branch
```

## 回滚

```bash
$ git reset [--soft | --mixed(default) | --hard] [HEAD~number | commit Id]
$ git revert [HEAD~number | commit Id]
```

## 提交历史

```bash
$ git log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short
```

## 储藏/弹出修改

```bash
$ git stash
$ git stash pop
```

## 标签

```bash
$ git tag
```

## 同步远端

```bash
$ git fetch
```

## 同步远端并合并

```bash
$ git pull remote branch [local branch]
```

## 同步到远端

```bash
$ git push remote branch
```


## 管理主机名

```bash
$ git remote [-v | add | rm | rename]
```

## 设置代理

```bash
$ git config --global https.proxy 'socks5://127.0.0.1:1086'
$ git config --global http.proxy 'socks5://127.0.0.1:8086'
```

## 取消代理

```bash
$ git config --global --unset https.proxy
$ git config --global --unset http.proxy
```

# `git` 子模块

## 子模块初始化拉代码

```bash
$ git submodule update --init
```

## 子模块拉远程代码

```bash
# 也可以进入子模块的文件夹 git pull
$ git submodule update --remote
```

## 添加子模块

```bash
$ git submodule add remote
```

## 删除子模块

```bash
$ git submodule deinit submodule
$ git rm --cached submodule
```

## 修改子模块 url

```bash
# 先 vim .gitmodules 修改对应子模块的 url
$ git submodule sync
```
