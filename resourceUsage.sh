#####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################

TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

echo ------------------------- top --------------------------
top -b -n 1 | head -n 5

echo ------------------------- netstat -ns --------------------------
netstat -ns

echo ------------------------- netstat -r --------------------------
netstat -r

