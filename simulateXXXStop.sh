#####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################


#!/bin/bash

TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

#echo $0 executing at `date`
echo $0 $MYIP executing at `date`

################################################3
# MAIN 
################################################3

#XXX_DIR=~/code/xxx/python
XXX_DIR=$TAGA_DIR/code/xxx/python

if [ $MYIP == "192.168.43.69" ]; then
   echo $0 $MYIP: stopping xxx daemon
   $XXX_DIR/xxx.py stop
elif [ $MYIP == "10.0.0.22" ]; then
   echo $0 $MYIP: stopping xxx daemon
   $XXX_DIR/xxx.py stop
else
   echo $0 $MYIP: stopping xxx daemon
   $XXX_DIR/xxx.py stop
fi

