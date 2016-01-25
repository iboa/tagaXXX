
TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

for target in $targetList
do
   echo processing, synchronizing config $target

   # build the source file string
   SCP_SOURCE_STR="$SCP_SOURCE_STR config"
   SCP_SOURCE_STR="$SCP_SOURCE_STR targetList.sh"
   SCP_SOURCE_STR="$SCP_SOURCE_STR hostList.txt"

   # send the files to the destination
   scp $SCP_SOURCE_STR $MYLOGIN_ID@$target:$TAGA_DIR <$TAGA_DIR/passwd.txt

done




