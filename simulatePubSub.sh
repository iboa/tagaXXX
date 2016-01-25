#!/bin/bash

TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

echo $0 executing at `date`

################################################3
# MAIN 
################################################3

#PUBSUB_DIR=~/code/nanomsg_app/PubSub
PUBSUB_DIR=$TAGA_DIR/code/nanomsg_app/PubSub

if [ $MYIP == "192.168.43.69" ]; then
   echo $0 $MYIP: running testPubSubServer
   $PUBSUB_DIR/testPubSubServer.sh 
elif [ $MYIP == "10.0.0.22" ]; then
   echo $0 $MYIP: running testPubSubServer
   $PUBSUB_DIR/testPubSubServer.sh 
else
   echo $0 $MYIP: running testPubSubClient 
   $PUBSUB_DIR/testPubSubClient.sh 
fi


