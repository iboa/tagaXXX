#####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################

TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

#ALIAS_FILE=$TAGA_DIR/aliasExamples.txt
ALIAS_FILE=$TAGA_DIR/aliasList.txt

# validate input
if [ $# -eq 1 ]; then
   echo; echo $0 : $MYIP :  executing at `date`; echo
else
   echo; echo $0 requires one parameter, exiting with no action...; echo
   exit
fi

##########################################################
# note, prior to running this script, # run the following: 
#
#    alias > $TAGA_DIR/aliasList.txt
##########################################################

# if confirmation, required, get the confirmation

if [ $CONFIRM_REQD -eq 1 ] ; then
   # ensure proper setup
   echo Please confirm that the following has been performed:
   echo "alias > $ALIAS_FILE"
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
fi

# source the aliases
echo source $ALIAS_FILE; echo
source $ALIAS_FILE

# init the counter
let i=1

# process the input
aliasNext=`alias $1`
RET=$?

if [ $RET -eq 0 ]; then
   echo $i: $aliasNext
   aliasNext=`echo $aliasNext | cut -d\' -f 2`
else
   echo Error: does $1 alias exist?; echo
   echo "Hint: considering running: alias > $ALIAS_FILE"; echo
   exit
fi 

# iterate until we hit the end of the trace
while [ $RET -eq 0 ] 
do
   # increment the count
   let i=$i+1
   echo $aliasNext
   #aliasNext=`alias $aliasNext 2>/dev/null` 2>/dev/null
   aliasNext=`alias $aliasNext 2>/dev/null` 
   RET=$?
   if [ $RET -eq 0 ]; then
      echo
      echo $i: $aliasNext
      aliasNext=`echo $aliasNext | cut -d\' -f 2`
   else
      echo; echo End of the Trace ; echo
   fi
done

