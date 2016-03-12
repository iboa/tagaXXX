#####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################

TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

echo
echo WARNING: This command will reboot the following: $OTHER_LIST
echo
echo Are you sure? \(y/n\) ?
echo

# issue confirmation prompt
./confirm.sh

let response=$?
if [ $response -eq 1 ]; then
  echo; echo Rebooting $OTHER_LIST ....; echo
else
  echo; echo Reboot $OTHER_LIST Command Not Confirmed, Exiting without action...; echo
  exit
fi

# reboot
for target in $OTHER_LIST
do
   echo
   echo processing $target
   if [ $target == $MYIP ]; then
      echo skipping self for now...
      continue
   fi
   echo rebooting $target .....
   ssh -l $MYLOGIN_ID $target sudo reboot <$SCRIPTS_DIR/taga/passwd.txt
done
echo


