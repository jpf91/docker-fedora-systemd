#!/bin/sh

HOST=$(hostname -f)
/usr/sbin/sendmail -t <<ERRMAIL
To: $SYSTEMD_EMAIL
From: $1 <root@$HOST>
Subject: $2 service status
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8

$(systemctl status --full "$2")
ERRMAIL