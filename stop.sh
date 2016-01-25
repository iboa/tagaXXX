
TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

KILL_LIST="tcpdump mgen" 

for proc_name in $KILL_LIST
do
   # Kill the process id(s) of the proc name
   echo kiling $proc_name ....
   KILL_LIST=`ps -ef | grep \$proc_name | grep -v grep | cut -c10-15` 
   sudo kill -9 $KILL_LIST <$TAGA_DIR/passwd.txt
done

