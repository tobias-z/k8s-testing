#!/usr/bin/env bash
echo "Hello world!" > index.html
nohup busybox httpd -f -p 80 &