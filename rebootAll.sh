#####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################

TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

echo
echo WARNING: This command will reboot all nodes in the network including the following: `echo $targetList`

echo
echo Are you sure? \(y/n\) ?
echo

read input

#echo $input

if [ $input == 'y' ]; then
  echo
  echo Rebooting All....
  echo
else
  echo
  echo Reboot All Command Not Confirmed, Exiting without action...
  echo
  exit
fi

for target in $targetList
do
   echo
   echo processing $target
   if [ $target == $MYIP ]; then
      echo skipping self for now...
      continue
   fi

   echo rebooting $target .....
   #ssh -l darrin $target sudo reboot 
   ssh -l darrin $target sudo reboot <$SCRIPTS_DIR/taga/passwd.txt

done
echo

echo rebooting self now...
#ssh -l darrin $MYIP sudo reboot
ssh -l darrin $MYIP sudo reboot <$SCRIPTS_DIR/taga/passwd.txt

