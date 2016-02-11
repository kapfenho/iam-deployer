#!/bin/sh

#  execute as root user

if [ $UID -ne 0 ] ; then /bin/echo "ERROR: not root" ; exit 77 ; fi
set -x

/usr/bin/yum update
/usr/bin/yum install -y haproxy

/bin/cat > /etc/haproxy/haproxy.cfg << EOS
#  haproxy config - part of IAM develop environment
#                                    vi:ft=haproxy:
#
global
    log         127.0.0.1 local2
    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon
    stats socket /var/lib/haproxy/stats

defaults
    mode      http
    log       global
    option    httplog
    option    dontlognull
    option    http-server-close
    option    forwardfor       except 127.0.0.0/8
    option    redispatch
    retries   3
    timeout   http-request    10s
    timeout   queue           1m
    timeout   connect         10s
    timeout   client          1m
    timeout   server          1m
    timeout   http-keep-alive 10s
    timeout   check           10s
    maxconn                 3000

frontend  main *:80
    default_backend         app

backend app
    balance     roundrobin
    server  app1 web1:7777 check
    server  app2 web2:7777 check
EOS

#  add to syslog
#
cf=/etc/rsyslog.conf

/bin/sed -i 's/^#\$ModLoad imudp/\$ModLoad imudp/g' ${cf}
/bin/sed -i 's/^#\$UDPServerRun/\$UDPServerRun/g'   ${cf}
/bin/echo "local2.*                       /var/log/haproxy.log" \
  > /etc/rsyslog.d/haproxy

/sbin/service   rsyslog reload
/sbin/chkconfig haproxy on
/sbin/service   haproxy start

exit 0
