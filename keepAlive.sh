#####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################

TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

# Note, suggest running this keepAlive.sh file with
# as nohup command, e.g. "nohup keepAlive.sh"

IP_TO_KEEP_ALIVE=192.168.43.208
ITFC_TO_KEEP_ALIVE=wlp2s0

while true
do
  sudo ifconfig $ITFC_TO_KEEP_AliVE $IP_TO_KEEP_ALIVE up
  sleep 60
  date
done
