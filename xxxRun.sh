#####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################

TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

for target in $targetList
do
   echo XXX processing on $target

   # exit now if XXX if off
   if [ $XXX_ON -eq 0 ]; then
      break
   fi

   ssh -l $MYLOGIN_ID $target $TAGA_DIR/device1.sh  <$TAGA_DIR/passwd.txt &
   ssh -l $MYLOGIN_ID $target $TAGA_DIR/device2.sh  <$TAGA_DIR/passwd.txt &
   ssh -l $MYLOGIN_ID $target $TAGA_DIR/device3.sh  <$TAGA_DIR/passwd.txt &
   ssh -l $MYLOGIN_ID $target $TAGA_DIR/device4.sh  <$TAGA_DIR/passwd.txt &
   ssh -l $MYLOGIN_ID $target $TAGA_DIR/device5.sh  <$TAGA_DIR/passwd.txt &

done



