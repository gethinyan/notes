#!/bin/bash
npm install
hexo g
scp -o StrictHostKeyChecking=no -r ./public/* root@47.52.175.26:/var/lib/docker/volumes/nginx-html/_data/blog/
echo 'travis build done!'
