#!/bin/bash

# Go to nginx home
cd /usr/local/openresty/nginx

# Start nginx
sbin/nginx

# Tail all log files
tail -f logs/*.log
