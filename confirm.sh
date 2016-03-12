#####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################

TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

echo
echo Please Confirm to Proceed.
echo
echo Confirm? \(y/n\) ?
#echo

read input

if [ $input == "y" ]; then
  exit 1 # confirmed
else
  exit 2 # not confirmed
fi

