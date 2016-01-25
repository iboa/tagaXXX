
TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

echo $TAGA_DIR

for target in $targetList
do
   echo processing $target

   ssh -l $MYLOGIN_ID $target mkdir -p /tmp/usr/local/lib
   scp -r /usr/local/lib/libnano* $MYLOGIN_ID@$target:/tmp/usr/local/lib <$TAGA_DIR/passwd.txt

   ssh -l $MYLOGIN_ID $target mkdir -p ~/code
   scp -r ~/code/* $MYLOGIN_ID@$target:~/code <$TAGA_DIR/passwd.txt

   ssh -l $MYLOGIN_ID $target mkdir -p $TAGA_DIR/code
   scp -r $TAGA_DIR/code/* $MYLOGIN_ID@$target:$TAGA_DIR/code <$TAGA_DIR/passwd.txt


done

