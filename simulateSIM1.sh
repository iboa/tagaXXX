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

SIM1_DIR=~/code/sim1/python
SIM1_DIR=$TAGA_DIR/code/sim1/python

# cleanup old processes, resources, sockets and such
OLDPROCFILE3="/home/$MYLOGIN_ID/python/python.pid"
rm $OLDPROCFILE3 2>/dev/null

if [ $MYIP == $DAEMON1_IP ]; then
   echo $0 $MYIP: starting sim1 daemon1
   $SIM1_DIR/sim1.py start
elif [ $MYIP == $DAEMON2_IP ]; then
   echo $0 $MYIP: starting sim1 daemon2
   $SIM1_DIR/sim1.py start
else
   echo $0 $MYIP: starting sim1 daemonXXX
   $SIM1_DIR/sim1.py start
fi


