#####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################

TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

# stop the simulations
for target in $targetList
do
   if [ $STOP_SIMULATION -eq 1 ] ; then
     echo STOP simulation processing on $target
     ssh -l $MYLOGIN_ID $target $TAGA_DIR/simulateStop.sh     & 
#     ssh -l $MYLOGIN_ID $target $TAGA_DIR/simulateXXXStop.sh  & 
#     ssh -l $MYLOGIN_ID $target $TAGA_DIR/simulateSIM1Stop.sh & 
   else
     echo NOT STOPING simulation processing on $target
   fi
done

# stop everything else
./stopAll.sh $outputDir

