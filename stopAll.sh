
TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

for target in $targetList
do
   echo processing, cleaning $target
   ssh -l $MYLOGIN_ID $target $TAGA_DIR/stop.sh  <$TAGA_DIR/passwd.txt
done


