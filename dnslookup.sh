#!/bin/bash
##############################################
# dnslookup - show A record for ELB hostname #
##############################################
### Task
#input:
#./dnslookup [dns record] [nameserver(default 8.8.8.8)]
#
#output (success):
#
#[date] [dns record@nameserver] [ip address 1...n (ip in sorted order)]
#
#output (any error):
#
#[date] [Error]
#
##### Example:
#./dnslookup prod-cthk-elb-gameserver-155363482.ap-southeast-1.elb.amazonaws.com 8.8.8.8
#
#[Mon Mar 23 14:53:29 HKT 2015] prod-cthk-elb-gameserver-155363482.ap-southeast-1.elb.amazonaws.com 54.169.62.64 54.179.137.222
#
#### Assignee : Karl

REC=$1
NS=@$2

if [ -z "$1" ]
then
   echo "Usage: ./dnslookup [hostname] [nameserver]" 
   exit 1
fi

if [ -z "$2" ]
then
    NS=''
fi

# random string for file name to store lookup result
HASH=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
FILE=/tmp/dnslookup-${HASH}

dig ${REC} ${NS} > ${FILE}
# get DIG date
DIGDATE=`grep WHEN ${FILE} | awk -F 'WHEN: '  '{ print $2 }'`
DATE=`date -d "${DIGDATE}" +"[%Y-%m-%d %H:%M:%S]"`

# get sorted IPs
IP=`grep ^${REC} ${FILE} | awk '{ print $5 }' | sort`

# get query nameserver
DNS=`grep SERVER ${FILE} | awk '{ print $3 }' | awk -F "#" '{ print $1 }'`

# show result
echo $DATE @${DNS}@ "#IP#" $IP

# clean up
rm -f ${FILE}

