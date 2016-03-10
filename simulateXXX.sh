#!/bin/bash

#####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################

TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

#echo $0 executing at `date`
echo $0 $MYIP executing at `date`

################################################3
# MAIN 
################################################3

#XXX_DIR=~/code/xxx/python
XXX_DIR=$TAGA_DIR/code/xxx/python

# cleanup old processes, resources, sockets and such
OLDPROCFILE3="/home/$MYLOGIN_ID/python/python.pid"
rm $OLDPROCFILE3 2>/dev/null

if [ $MYIP == "192.168.43.69" ]; then
   echo $0 $MYIP: starting xxx daemon
   $XXX_DIR/xxx.py start
elif [ $MYIP == "10.0.0.22" ]; then
   echo $0 $MYIP: starting xxx daemon
   $XXX_DIR/xxx.py start
else
   echo $0 $MYIP: starting xxx daemon
   $XXX_DIR/xxx.py start
fi

