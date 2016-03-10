#####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################

TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

if [ $START_OF_CYCLE_TESTS_ENABLED == 1 ]; then
  echo $0 Start of Cycle Tests Enabled - proceeding...
else
  echo $0 Start of Cycle Tests Disabled - Exiting
  exit
fi

COMMON_PARAMS="--user=$MYLOGIN_ID --password=$MYPASSWD --batch-mode"

for target in $targetList
do
  TEE_FILE=/tmp/startOfCycleTest_$target.out
  echo $COMMAND :`date` : hostname:`hostname` target:$target -------------------------- | tee $TEE_FILE
  $COMMAND --server=$target $COMMON_PARAMS --run-command="list commands" >> $TEE_FILE 
  $COMMAND --server=$target $COMMON_PARAMS --run-command="get-config --source=running" >> $TEE_FILE 
  $COMMAND --server=$target $COMMON_PARAMS --run-command="get-my-session" >> $TEE_FILE 

done



