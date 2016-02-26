#####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################




TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

MY_PARAM_IP=$1
#echo $MY_PARAM_IP

if [ $MYIP == "localhost" ] ; then
  MYINTERFACE="lo"
else
  MYINTERFACE=`ifconfig | grep $MY_PARAM_IP -B1 | head -n 1 | cut -d" " -f1`
fi

#echo $MYINTERFACE

echo $0 executing at `date`


if $TAGA_DIR/hostList.sh | grep `hostname` >/dev/null ; then

  echo Running tcpdump on `hostname` | tee $STATUS_FILE 

  tcpdump -n -s 200 -i $MYINTERFACE udp port $SOURCEPORT -l        \
     <$SCRIPTS_DIR/taga/passwd.txt | tee                         \
     /tmp/$TEST_DESCRIPTION\_`hostname`_$MYINTERFACE\_$MY_PARAM_IP\_`date +%j%H%M%S` 

else
  echo `hostname` is not in the list of PLI Receivers | tee $STATUS_FILE 
  echo $0 Exiting with no action | tee $STATUS_FILE 
fi

