#####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################

TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

echo $0 executing at `date`

# get the input 
MY_PARAM_IP=$1

# set the proto
if [ $TESTTYPE == "UCAST_TCP" ]; then
   myproto=tcp
else
   myproto=udp
fi

# add special handling for localhost
if [ $MYIP == "localhost" ] ; then
  MYINTERFACE="lo"
else
  MYINTERFACE=`ifconfig | grep $MY_PARAM_IP -B1 | head -n 1 | cut -d" " -f1`
fi

# if we are in the listener list, then listen for traffic
if $TAGA_DIR/hostList.sh | grep `hostname` >/dev/null ; then

  echo Running tcpdump on `hostname` | tee $STATUS_FILE 

  tcpdump -n -s 200 -i $MYINTERFACE $myproto port $SOURCEPORT -l        \
     <$SCRIPTS_DIR/taga/passwd.txt | tee                         \
     /tmp/$TEST_DESCRIPTION\_`hostname`_$MYINTERFACE\_$MY_PARAM_IP\_`date +%j%H%M%S` 

else
  echo `hostname` is not in the list of Traffic/PLI Receivers | tee $STATUS_FILE 
  echo $0 Exiting with no action | tee $STATUS_FILE 
fi

