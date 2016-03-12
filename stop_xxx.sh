#####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################

TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

# Kill xxx_xxx
KILL_LIST=`ps -ef | grep xxx_xxx | grep -v grep | cut -c10-15` 
sudo kill -9 $KILL_LIST <$SCRIPTS_DIR/taga/passwd.txt

