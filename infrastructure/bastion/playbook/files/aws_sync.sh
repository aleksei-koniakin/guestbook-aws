#!/bin/sh

/usr/local/bin/aws s3 sync --delete $(cat /etc/keybucket) /var/keys
/bin/chmod 644 /var/keys/*
