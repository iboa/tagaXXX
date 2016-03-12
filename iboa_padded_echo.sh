#####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################

TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

if [ $# -ne 2 ]; then
    echo $0: Error, two params required!
   echo "   required param 1: output param to be padded"
   echo "   required param 2: size of output after padding"
   exit 255
fi

#echo; echo $0 : $MYIP :  executing at `date`; echo

## issue confirmation prompt
#./confirm.sh
## check the response
#let response=$?
#if [ $response -eq 1 ]; then
#  echo; echo Confirmed, $0 continuing....; echo
#else
#  echo; echo Not Confirmed, $0 exiting with no action...; echo
#  exit
#fi
#

outputParam=$1
printlen=$2

buflen=`echo $outputParam | awk '{print length($0)}'`

let padlen=$printlen-$buflen
# add the padding
let i=$padlen
while [ $i -gt 0 ];
do
  outputParam="$outputParam."
  let i=$i-1
done

echo $outputParam




