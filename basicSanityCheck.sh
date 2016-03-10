#####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################

TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

if echo $MYLOGIN_ID | grep GoesHere >/dev/null ; then
   echo
   echo WARNING: It appears you have not updated the config file with your configuration information
   echo e.g. [ MYLOGIN_ID: $MYLOGIN_ID ]
   echo
   exit 255
elif echo $MYPASSWD | grep GoesHere >/dev/null ; then
   echo
   echo WARNING: It appears you have not updated the config file with your configuration information
   echo e.g. [ MYPASSWD: $MYPASSWD ]
   echo
   exit 255
else
   echo Basic Check Passed >/dev/null
fi

exit 0

