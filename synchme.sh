#####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################

TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

MYDIR=`pwd`
MYDIR=$TAGA_DIR

for target in $targetList
do

   if [ $MYIP == $target ]; then
      echo skipping self...
   else
      echo processing, synchronizing $target
      sleep 1
      # build the source file string
      SCP_SOURCE_STR="code"
      # send the files to the destination
      ssh -l $MYLOGIN_ID $target mkdir -p $MYDIR
      scp -r $SCP_SOURCE_STR $MYLOGIN_ID@$target:$MYDIR \
              <$TAGA_DIR/passwd.txt
   fi

done

