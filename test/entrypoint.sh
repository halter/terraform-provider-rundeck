#!/bin/bash

cp -r /mnt/etc/remco/* /etc/remco/
exec /tini -- docker-lib/entry.sh
