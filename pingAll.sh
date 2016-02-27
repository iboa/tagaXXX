#####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################

TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

PING_COUNT=10
SLEEP_TIME=1

MYGATEWAY=10.0.0.1

while true
do
   echo
   date
   echo

   # ping the gateway!
   ping -c $PING_COUNT $MYGATEWAY

   sleep $SLEEP_TIME

   for target in $targetList
   do
      echo
      ping -c $PING_COUNT $target
      sleep $SLEEP_TIME
   done

done

