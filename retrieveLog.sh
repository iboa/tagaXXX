#####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################

TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

for target in $MASTER
do
   if [ $target == $MYIP ]; then
     echo skipping self \($target\)
     continue
   fi

   echo processing, synchronizing $target
   sleep 1

   # build the source file string
   SCP_SOURCE_STR="*"    

   sudo mkdir -p $LOG_DIR
   sudo chmod 777 $LOG_DIR
   scp -r $MYLOGIN_ID@$target:$LOG_DIR/$SCP_SOURCE_STR $LOG_DIR <$TAGA_DIR/passwd.txt

done

