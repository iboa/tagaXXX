#####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################

TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

# get the input
iter=$2
startTime=$3
startDTG=$4

##################################################################
# Print Header Rows
##################################################################

# print header row
echo;echo
echo >> $TAGA_DIR/counts.txt

#echo `date` Iteration:$iter StartDTG: $startTime $startDTG $TESTTYPE
#echo `date` Iteration:$iter StartDTG: $startTime $startDTG $TESTTYPE >> $TAGA_DIR/counts.txt

row="$1 TABLE ------------------------------  RECEIVERS LIST ------------------------------------"
if [ $NARROW_DISPLAY -eq 1 ]; then
  row="$1 TABLE   ------------------ RECEIVERS LIST --------------------"
fi
echo "$row"
echo "$row" >> $TAGA_DIR/counts.txt


row="   1    2    3    4    5    6    7    8    9   10   11   12   13   14   15   16   17   18   19   20"
if [ $NARROW_DISPLAY -eq 1 ]; then
  row="1    2    3    4    5    6    7    8    9    10   Tot"
fi
echo "SENDERS LIST      $row"
echo "SENDERS LIST      $row" >> $TAGA_DIR/counts.txt


  row="------------     ---- ---- ---- ---- ---- ---- ---- ---- --- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----"
if [ $NARROW_DISPLAY -eq 1 ]; then
  row="------------      ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----"
fi
echo "$row"
echo "$row" >> $TAGA_DIR/counts.txt


