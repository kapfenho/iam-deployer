#!/bin/bash -x

set -o errexit nounset

lb_ipaddr=192.168.1.242

if ! /sbin/service iptables status >/dev/null ; then
  /sbin/service iptables start
fi

if ! /sbin/chkconfig iptables >/dev/null ; then
  /sbin/chkconfig iptables on
fi

/sbin/iptables -t nat -A PREROUTING -p tcp -m tcp --dport 80 \
  -d ${lb_ipaddr} -j DNAT --to-destination :7777
/sbin/iptables -t nat -A PREROUTING -p tcp -m tcp --dport 443 \
  -d ${lb_ipaddr} -j DNAT --to-destination :4443
/sbin/iptables -t nat -A OUTPUT -p tcp -m tcp --dport 80 \
  -d ${lb_ipaddr} -j DNAT --to-destination :7777
/sbin/iptables -t nat -A OUTPUT -p tcp -m tcp --dport 443 \
  -d ${lb_ipaddr} -j DNAT --to-destination :4443

/sbin/service iptables save

