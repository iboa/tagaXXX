#!/bin/bash

#####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################

TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

#echo $0 executing at `date`
echo $0 $MYIP executing at `date`

# if started with flag then use it
if [ $# -eq 1 ]; then
  echo creating /tmp/simulationFlag.txt with 1 flag set to: $1
  # override the value from the config
  let MAX_ENVIRON_SIM_LOOPS=1
  echo $1 > /tmp/simulationFlag.txt
fi


#####################################
# SIMULATE FUNCTION
#####################################

function doSimulate {

  myinterface=$INTERFACE

  let CONFIG_DELAY=10

  #for myiter in 1 2 3 4 5 
  #for myiter in 1 2
  for myiter in 1 
  do

    echo $myinterface going down... 
    sudo ifconfig $myinterface down
    sleep $CONFIG_DELAY

    echo $myinterface going up... 
    sudo ifconfig $myinterface up <$TAGA_DIR/passwd.txt
    sleep $CONFIG_DELAY

  done
}

################################################3
# MAIN 
################################################3

# One Time / Single Operation Invocations

# cleanup old processes, resources, sockets and such
rm $OLDPROCFILE1 2>/dev/null 
rm $OLDPROCFILE2 2>/dev/null
rm $OLDPROCFILE3 2>/dev/null

# start the server

# starting of servers moved external, note the cleanup above is still vital on each node
if [ $PRIMARY_SIM_SERVER_ON -eq 1 ]; then

   echo Primary Simulation Server Enabled - starting Server.....

   # start the primary sim server

   PRIMARY_SERVER_STARTCMD="$PRIMARY_SERVER_COMMAND --log-level=debug --log=/tmp/$PRIMARY_SERVER_COMMAND.log"
   $PRIMARY_SERVER_STARTCMD &

else
   echo Primary Simulation Server Disabled - *not* starting Server.....
fi


################################################3
# Main Init
################################################3
let i=$MAX_ENVIRON_SIM_LOOPS
if [ $i -eq 0 ]; then
  echo $0 exiting since ENVIRON environ simulationFlag is disabled
  exit
fi

################################################3
# MAIN LOOP
################################################3
while true
do

  # assume no simulation (assume sim flag = 0)
  # touch sim flag in case it is not there 
  touch /tmp/simulationFlag.txt

  # get simulation flag from the master
  scp $MYLOGIN_ID@$MASTER:/tmp/simulationFlag.txt /tmp >/dev/null 2>/dev/null

  MYFLAG=`cat /tmp/simulationFlag.txt`
  if [ $MYFLAG -eq 1 ] ; then

    # open loop
    echo `date` $MYIP ENVIRON simulation in progress
    echo $MYIP ENVIRON Simulation In Progress... > /tmp/simulation.out
    echo $MYIP my master is $MASTER  >> /tmp/simulation.out

    #############################################
    # Do the simulation
    #############################################
    doSimulate

    # close loop
    echo `date` $MYIP ENVIRON simulation in progress
    echo `date` $MYIP ENVIRON simulation in progress >>/tmp/simulation.out
    sleep 5

  else
   echo $0 exiting since ENVIRON environ simulationFlag is disabled
   exit
  fi

  let i=$i-1
  if [ $i -eq 0 ]; then
   echo $0 exiting since max simulation loops achieved
   exit
  fi

done
