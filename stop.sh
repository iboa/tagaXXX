#####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################

TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

KILL_LIST="tcpdump mgen survey xxx" 

for proc_name in $KILL_LIST
do
   # Kill the process id(s) of the proc name
   echo kiling $proc_name ....
   KILL_LIST2=`ps -ef | grep \$proc_name | grep -v grep | cut -c10-15` 
   echo Kill_list: $KILL_LIST2
   sudo kill -9 $KILL_LIST2 <$TAGA_DIR/passwd.txt < $TAGA_DIR/passwd.txt
done

