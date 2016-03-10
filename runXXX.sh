#####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################

TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

# exit now if XXX if off
if [ $XXX_ON -eq 0 ]; then
  echo $0 - XXX simulation is OFF, exiting with no action on $MYIP
  exit
fi

for target in $targetList
do

   echo XXX processing on $target
  
   if [ $DEVICE1_ON -eq 1 ]; then
     ssh -l $MYLOGIN_ID $target $TAGA_DIR/xxx_xxx.sh Device1 /tmp/device1.data /tmp/device1.out <$TAGA_DIR/passwd.txt &
   fi
   if [ $DEVICE2_ON -eq 1 ]; then
     ssh -l $MYLOGIN_ID $target $TAGA_DIR/xxx_xxx.sh Device2 /tmp/device1.data /tmp/device2.out <$TAGA_DIR/passwd.txt &
   fi
   if [ $DEVICE3_ON -eq 1 ]; then
     ssh -l $MYLOGIN_ID $target $TAGA_DIR/xxx_xxx.sh Device3 /tmp/device1.data /tmp/device3.out <$TAGA_DIR/passwd.txt &
   fi
   if [ $DEVICE4_ON -eq 1 ]; then
     ssh -l $MYLOGIN_ID $target $TAGA_DIR/xxx_xxx.sh Device4 /tmp/device1.data /tmp/device4.out <$TAGA_DIR/passwd.txt &
   fi
   if [ $DEVICE5_ON -eq 1 ]; then
     ssh -l $MYLOGIN_ID $target $TAGA_DIR/xxx_xxx.sh Device5 /tmp/device1.data /tmp/device5.out <$TAGA_DIR/passwd.txt &
   fi

done



