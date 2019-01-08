---
title: 使用 Hexo + Next 搭建博客
date: 2019-01-04 18:39:30
tags:
  - Hexo
  - GitHub Pages
  - Next
  - travis
  - deploy
---


# Hexo

## 什么是 Hexo？

 - Hexo 是一个快速、简洁且高效的博客框架

 - Hexo 使用 Markdown（或其他渲染引擎）解析文章，在几秒内，即可利用靓丽的主题生成静态网页

## 安装 Hexo

### 安装前请确保已经安装以下环境
 - Node.js
 - git

### 安装 Hexo 命令

```bash
$ npm install -g hexo-cli
```

### 安装完成后执行以下命令即可

```bash
# 进入你期望存放的目录创建 blog 文件夹
$ cd ~ && mkdir blog
# 使用 hexo 初始化 blog
$ hexo init blog
$ cd blog
$ npm install
# 启动服务器。默认情况下，访问网址为： http://localhost:4000/
$ hexo s
```

至此，我们已经完成了万里长征的第一步，但是 Hexo 默认的主题不太好看，推荐使用简洁好看的 [Next](http://theme-next.iissnan.com) 主题，下面介绍如何结合 [Next](http://theme-next.iissnan.com)

<!-- more -->

# 使用 Next 主题

## 安装 Next 主题

### 在终端窗口下，定位到 Hexo 站点目录下

```bash
$ cd ~/blog
$ git clone https://github.com/theme-next/hexo-theme-next themes/next
```

### 启用 Next 主题，打开 `~/blog/_config.yml` 修改 `theme`

```bash
theme: next
```

### 重新启动服务器

```bash
$ hexo s
```

> 好了，现在打开 `http://0.0.0.0:4000/` 看看我们的博客发生了什么变化吧

# 上传到 github 通过 `username.github.io` 访问

## 部署博客代码

### 安装 `hexo-deployer-git`

```bash
$ npm install hexo-deployer-git --save
```

### 打开 `~/blog/_config.yml` 配置 deploy

```bash
deploy:
  type: git
  repo: https://github.com/gethinyan/gethinyan.github.io.git # 替换为你的仓库路径
  branch: master
```

### 部署代码，部署前需要创建仓库 `username.github.io`

```bash
hexo d -g
```

现在打开 ~~`http://0.0.0.0:4000/`~~ `https://username.github.io/` 看看是否成功了呢

# 使用 travis 完成自动构建、部署

## Activate repository

在做下面的操作前请先打开 [https://www.travis-ci.org](https://www.travis-ci.org/) active 你的 Hexo 项目

### 设置 Environment Variables

 - 打开 settings 页面
 - 添加 Environment Variables
 - 添加变量 GITHUB_TOKEN，值在 [https://github.com/settings/tokens](https://github.com/settings/tokens) 生成即可

### 在 Hexo 项目根目录添加文件 `.travis.yml`

```bash
language: node_js
node_js: stable
cache:
  apt: true
  directories:
    - node_modules
install:
- npm install
script:
- hexo clean
- hexo g
after_script:
- cd ./public
- git init
- git config user.name "gethin.yan"
- git config user.email "gethin.yan@gmail.com"
- git add .
- git commit -m "update notes"
- git push --force --quiet "https://${GITHUB_TOKEN}@${GH_REF}" master:master
branches:
  only:
  - master
env:
  global:
  - GH_REF: github.com/gethinyan/gethinyan.github.io.git
```

现在试试把 Hexo 的代码 push 到 github 上，打开 [https://www.travis-ci.org](https://www.travis-ci.org/) 对应项目的 `Build History`，查看构建的过程，成功后你会发现仓库 `username.github.io` 的文件刚被更新

## `github Webhooks` 实现服务器自动拉代码

> 以下的文档适用于有自己的云服务器的盆友，想要实现自动部署博客代码到自己的服务器上

### 添加 webhook

打开仓库 `username.github.io` 的 `settings > Webhooks` 添加一个 webhook，值为 `http://yourip:10002/`，secret 自己设置一个，在下面的脚本需要用到

### 开启服务监听 webhook 配置的 10002 端口

现在需要开启一个服务监听 10002 端口并且 secret 是 Webhook 配置的 secret，然后执行一个脚本 `deploy.sh`，在脚本里面去拉最新的代码到我们的 webroot

```bash
# webhook.js
const http = require('http')
const webhookHandler = require('github-webhook-handler')

const handler = webhookHandler({ path: '/', secret: '123456' })

function cmd (cmd, args, callback) {
  const spawn = require('child_process').spawn
  const child = spawn(cmd, args)
  let res = ''

  child.stdout.on('data', buffer => { res += buffer.toString() })
  child.stdout.on('end', () => { callback(res) })
}

http.createServer((req, res) => {
  handler(req, res, err => {
    res.statusCode = 404
    res.end('no such loacion')
  })
}).listen(10002)

handler.on('error', err => {
  console.error('Error: ', err.message)
})

handler.on('push', event => {
  const { repository, ref } = event.payload
  console.log(`Reveived a push event for ${repository.name} to ${ref}`)
  cmd('sh', ['./deploy.sh', repository.name], text => {
    console.log(text)  })
})
```

### 启动服务

```bash
$ yarn global add pm2
$ pm2 start webhook.js
$ pm2 startup
```

不妨试试添加一个 test.md 并发布 push 到 github，首先在 travis 构建部署成功，然后触发 webhook，最后新的代码部署到我们的服务器，打开你的博客地址就能看到 test 了

# travis 命令实现免登录 ssh 部署代码

## 安装 travis

### 安装 ruby

```bash
$ yum install rubygems
```

### 更新 gem，设置镜像源

```bash
$ gem update --system
$ gem sources --add https://gems.ruby-china.org/
```

### 使用 gem 安装 travis

```bash
$ gem install travis
```

## travis 配置

### 登录 travis

```bash
$ travis login
```

### 使用 travis 加密公钥文件

```bash
$ travis encrypt-file ~/.ssh/id_rsa --add
```

### 查看 `.travis.yml` 的变化

```bash
before_deploy:
- openssl aes-256-cbc -K $encrypted_99fb0ffd7f47_key -iv $encrypted_99fb0ffd7f47_iv
  -in id_rsa.enc -out /tmp/id_rsa -d
- eval "$(ssh-agent -s)"
- chmod 600 /tmp/id_rsa
- ssh-add /tmp/id_rsa

after_success:
  - ssh -o StrictHostKeyChecking=no root@youtip "bash ./deploy.sh"
```
