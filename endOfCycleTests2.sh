#####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################

TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

if [ $END_OF_CYCLE_TESTS2_ENABLED == 1 ]; then
  echo $0 End of Cycle Tests2 Enabled - proceeding...
else
  echo $0 End of Cycle Tests2 Disabled - Exiting
  exit
fi

COMMON_PARAMS="--user=$MYLOGIN_ID --password=$MYPASSWD --batch-mode"


for target in $targetList
do
  TEE_FILE=/tmp/endOfCycleTest2_$target.out
  TEE_FILE=/tmp/endOfCycleTest2_$target.out
  echo $COMMAND :`date` : hostname:`hostname` target:$target -------------------------- | tee $TEE_FILE
  $COMMAND --server=$target $COMMON_PARAMS --run-command="list commands" >> $TEE_FILE 
  $COMMAND --server=$target $COMMON_PARAMS --run-command="get-config --source=running" >> $TEE_FILE 
done


