
TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config


echo $0 executing at `date`


if $TAGA_DIR/hostList.sh | grep `hostname` >/dev/null ; then

  echo Running tcpdump on `hostname` | tee $STATUS_FILE 

  tcpdump -n -s 200 -i $INTERFACE udp port $SOURCEPORT -l <$SCRIPTS_DIR/taga/passwd.txt | tee /tmp/taga_ucast_`hostname`_`date +%j%H%M%S` 

else
  echo `hostname` is not in the list of PLI Receivers | tee $STATUS_FILE 
  echo $0 Exiting with no action | tee $STATUS_FILE 
fi

