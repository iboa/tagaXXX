#####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################

TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

for target in $targetList
do
   echo
   echo processing $target
   ssh -l $MYLOGIN_ID $target hostname
   ssh -l $MYLOGIN_ID $target date
done
echo


