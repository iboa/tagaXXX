#####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################

TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

echo
echo WARNING: This command will reboot the following: $REBOOT_ONE_LIST
echo
echo Are you sure? \(y/n\) ?
echo

read input

if [ $input == 'y' ]; then
  echo
  echo Rebooting $REBOOT_ONE_LIST ....
  echo
else
  echo
  echo Reboot $REBOOT_ONE_LIST Command Not Confirmed, Exiting without action...
  echo
  exit
fi

for target in $REBOOT_ONE_LIST
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

#echo rebooting self now...
#ssh -l $MYLOGIN_ID $MYIP sudo reboot <$SCRIPTS_DIR/taga/passwd.txt

