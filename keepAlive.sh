#####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################

TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

IP_TO_KEEP_ALIVE=192.168.43.208
ITFC_TO_KEEP_ALIVE=wlp2s0

while true
do
  echo sudo ifconfig $ITFC_TO_KEEP_ALIVE $IP_TO_KEEP_ALIVE up
  sudo ifconfig $ITFC_TO_KEEP_ALIVE $IP_TO_KEEP_ALIVE up
  sleep 60
  date
done
