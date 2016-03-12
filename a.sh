#####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################

TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

echo $0 : $MYIP :  executing at `date`

# issue confirmation prompt
./confirm.sh
# check the response
let response=$?
if [ $response -eq 1 ]; then
  echo; echo Confirmed, $0 continuing....; echo
else
  echo; echo Not Confirmed, $0 exiting with no action...; echo
  exit
fi
