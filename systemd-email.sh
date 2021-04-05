#!/bin/sh

/usr/sbin/sendmail -t <<ERRMAIL
To: $MAIL_TO
From: $1 <root@$MAIL_FROM_DOMAIN>
Subject: $2 service status
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8

$(systemctl status --full "$2")
ERRMAIL