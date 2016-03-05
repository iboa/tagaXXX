#####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################

TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

echo ------------  top `hostname` top $MYIP --------------------------
sleep 1
top -b -n 1 | head -n 5

echo ------------  ifconfig `hostname` ifconfig $MYIP --------------------------
sleep 1
ifconfig

echo ------------  netstat -ns `hostname` netstat -ns $MYIP --------------------------
sleep 1
netstat -ns

echo ------------  netstat -r  \(route\) `hostname` $MYIP ---------------------
sleep 1
netstat -r

