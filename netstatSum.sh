#####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################

TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

netstat -ant | awk '{print $6}' | sort | uniq -c | sort -n
