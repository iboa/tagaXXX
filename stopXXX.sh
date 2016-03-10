#####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################

TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

# exit now if XXX is off
if [ $XXX_ON -eq 0 ]; then
  echo $0 - XXX simulation is OFF, exiting with no action on $MYIP
  exit
fi

for target in $targetList
do
   echo STOP XXX simulation on $target
   ssh -l $MYLOGIN_ID $target $TAGA_DIR/stop_xxx.sh  <$SCRIPTS_DIR/taga/passwd.txt &
done



