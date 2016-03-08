#####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################

#TAGA_DIR=/opt/iboa

TAGA_DIR=~/scripts/taga
TAGA_DIR=`pwd`
source $TAGA_DIR/config

#for target in 10.0.0.20
for target in $targetList
do
   if [ $target == $MYIP ]; then
     echo skipping self \($target\)
     continue
   fi

   echo processing, synchronizing $target
   sleep 1

   # build the source file string
   SCP_SOURCE_STR="*.sh"                       # add *.sh files
   SCP_SOURCE_STR="$SCP_SOURCE_STR *.txt"      # add *.txt files 
   SCP_SOURCE_STR="$SCP_SOURCE_STR host*"      # add host* files
   SCP_SOURCE_STR="$SCP_SOURCE_STR config"     # add config files
   SCP_SOURCE_STR="$SCP_SOURCE_STR *.template" # add template files
   SCP_SOURCE_STR="$SCP_SOURCE_STR code"       # add code subdir

   # send the files to the destination
   # ssh -l $MYLOGIN_ID $target "sudo mkdir $TAGA_DiR         2>/dev/null"
   # ssh -l $MYLOGIN_ID $target "sudo chmod 777 $TAGA_DIR     2>/dev/null"
   #ssh -l $MYLOGIN_ID $target "sudo mkdir /opt/iboa          2>/dev/null"
   #ssh -l $MYLOGIN_ID $target "sudo chmod 777 /opt/iboa      2>/dev/null"
   #ssh -l $MYLOGIN_ID $target "sudo mkdir /opt/iboa/taga     2>/dev/null"
   #ssh -l $MYLOGIN_ID $target "sudo chmod 777 /opt/iboa/taga 2>/dev/null"
   ssh -l $MYLOGIN_ID $target "sudo mkdir -p $TAGA_DIR   2>/dev/null"
   ssh -l $MYLOGIN_ID $target "sudo chmod 777 $TAGA_DIR  2>/dev/null"
   scp -r $SCP_SOURCE_STR $MYLOGIN_ID@$target:$TAGA_DIR <$TAGA_DIR/passwd.txt

   # update the links to the new dir
#   ssh -l $MYLOGIN_ID $target "rm ~/scripts/taga 2>/dev/null"
#   #ssh -l $MYLOGIN_ID $target "ln -s $TAGA_DIR ~/scripts/taga 2>/dev/null"
#   ssh -l $MYLOGIN_ID $target "ln -s $TAGA_DIR ~/scripts/taga 2>/dev/null"

   # clean up old OBE scripts (run once per file in all environs)
   # but check the flag first
   # flip the flag once I have been run in all environs
   if [ $EXTRA_FILE_CLEANUP_ENABLED -eq 0 ]; then
      continue
   fi

done

