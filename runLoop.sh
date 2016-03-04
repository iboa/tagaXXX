#####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################

TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

#########################################
# Update the MASTER entry in the config
# strip old MASTER entries and blank lines at end of file
#########################################
cat $TAGA_DIR/config | sed -e s/^MASTER=.*$//g |     \
      sed -e :a -e '/./,$!d;/^\n*$/{$d;N;;};/\n$/ba' \
           > $TAGA_DIR/tmp.config

# move temp to config
mv $TAGA_DIR/tmp.config $TAGA_DIR/config

# Update the MASTER entry in the config
echo MASTER=$MYIP >> $TAGA_DIR/config
echo $ENVIRON_SIMULATION > /tmp/simulationFlag.txt

# source again due to above as well as other boot strap-like dependencies
# note, this may not be necessary and is candidate to investigate 
source $TAGA_DIR/config

echo;echo
if [ $TESTONLY -eq 1 ] ; then
  # use the testing directory for testing
  echo NOTE: Config file is configured for TESTONLY!!
  echo NOTE: Output Dir is NOT being Archived!!
else
  # use the archive directory for archiving
  echo NOTE: Config file is configured for ARCHIVING.
  echo NOTE: Output Dir IS being Archived!!
fi 

sleep 1

echo;echo;echo
echo $0 initializing....  please be patient...
echo;echo

# check time synch if enabled
if [ $TIME_SYNCH_CHECK_ENABLED -eq 1 ]; then
  ./timeSynchCheck.sh
fi
sleep 1

# get ping times if enabled
if [ $PING_TIME_CHECK_ENABLED -eq 1 ]; then
  ./pingTimes.sh
fi
sleep 1

# stop the Simulation Always 
if [ true ] ; then
#if [ $STOP_SIMULATION -eq 1 ] ; then
  ./stopXXX.sh
fi

# stop the Simulation and Data Generation in case it is still running somewhere
./runStop.sh

# do a complete synch at least once
./synch.sh

let iter=0
startTime="`date +%T`"
startDTG="`date`"

while true
do

   # check time synch if enabled
   if [ $TIME_SYNCH_CHECK_ENABLED -eq 1 ]; then
     ./timeSynchCheck.sh
   fi
   sleep 1

   # get ping times if enabled
   if [ $PING_TIME_CHECK_ENABLED -eq 1 ]; then
     ./pingTimes.sh
   fi
   sleep 1

   # new 15 jan 2016
   # Update the MASTER entry in the config
   # strip old MASTER entries and blank lines at end of file
   cat $TAGA_DIR/config | sed -e s/^MASTER=.*$//g |     \
         sed -e :a -e '/./,$!d;/^\n*$/{$d;N;;};/\n$/ba' \
             > $TAGA_DIR/tmp.config
   mv $TAGA_DIR/tmp.config $TAGA_DIR/config

   # Update the MASTER entry in the config
   echo MASTER=$MYIP >> $TAGA_DIR/config
   echo $ENVIRON_SIMULATION > /tmp/simulationFlag.txt

   let iter=$iter+1

   # get the config again in case it has changed
   source $TAGA_DIR/config

   while [ $ALL_TESTS_DISABLED -eq 1 ] 
   do
      # refresh the flag to check again
      source $TAGA_DIR/config
      echo
      echo `date` Main Test Loop Disabled ............
      sleep 5
   done

   echo
   echo `date` Main Test Loop Enabled ............

   # exit now if simulation only
   if [ $SIMULATION_ONLY -eq 1 ]; then
      echo `date` Simulation Only Flag is True
      echo `date` Background Traffic is Disabled ............
   fi

   echo
   echo `date` Regenerating HostToIpMap File ............

   # build the map each iteration
   ./createHostToIpMap.sh

   echo `date` Regenerating HostToIpMap File ............ DONE
   echo

   if [ $CONTINUOUS_SYNCH -eq 1 ]; then
     # synch everything 
     ./synch.sh
   else
     # synch config only
     ./synchConfig.sh
   fi

   # baseline the aggregate log file
   cp /tmp/runLoop.sh.out /tmp/runLoop.sh.out.before

   # temp/test directory
   mkdir -p $OUTPUT_DIR

   # archive directory
   outputDir=$OUTPUT_DIR/output_`date +%j%H%M%S` 
   mkdir -p $outputDir

   # start the Simulation 
   if [ $START_SIMULATION -eq 1 ] ; then

     # Init the sims (cleanup old files/sockets)
     ./simulateInit.sh

     # Init the selected sims (cleanup old files/sockets)
     # XXX RUN SCRIPT
     if [ $XXX_ON -eq 1 ]; then
       ./runXXX.sh
     fi
   fi

   # MAIN RUN SCRIPT (primary sim server and traffic)
   ./run.sh

   # Start of cycle tests
   sleep $SERVER_INIT_DELAY

   ./startOfCycleTests.sh & # run in background/parallel

   let i=$DURATION1
   while [ $i -gt 0 ]
   do
      let tot=$DURATION2+$i
      echo Total Secs Remain: $tot : Secs Remain Part 1: $i
      sleep 1
      let i=$i-1
   done

   # Mid cycle tests
   ./midCycleTests.sh & # run in background/parallel

   let i=$DURATION2
   while [ $i -gt 0 ]
   do
      let tot=$i
      echo Total Secs Remain: $tot : Secs Remain Part 2: $i
      sleep 1
      let i=$i-1
   done

   #####################################################
   # Client-Side Test Stimulations
   #####################################################

   # End of cycle tests
   ./endOfCycleTests.sh
   ./endOfCycleTests2.sh
   ./endOfCycleTests3.sh

   #####################################################
   # Client-Side Specialized Test Stimulations
   #####################################################

   if [ $XXX_ON -eq 1 ]; then
     ./testXXX.sh
   fi
 
   sleep 5

   # stop the Simulation each iteration 
   if [ $STOP_SIMULATION -eq 1 ] ; then
      ./stopXXX.sh
   fi

   # stop the Remaining Simulation and Data Generation
   ./runStop.sh

   # collect and clean
   ./collect.sh $outputDir
   ./cleanAll.sh $outputDir

   # remove old and put current data in generic output directory
   rm -rf $OUTPUT_DIR/output
   cp -r $outputDir $OUTPUT_DIR/output

   # count and sort and display results matrix
   ./countSends.sh $outputDir $iter $startTime $startDTG
   ./countReceives.sh $outputDir $iter $startTime $startDTG 
   sleep 5

   # remove old and put current data in generic output directory
   #rm -rf $OUTPUT_DIR/output
   #cp -r $outputDir $OUTPUT_DIR/output

   # move output to the archive
   mv $TAGA_DIR/output/output_* $SCRIPTS_DIR/archive 2>/dev/null

   # re-baseline the aggregate log file
   cp /tmp/runLoop.sh.out /tmp/runLoop.sh.out.after

   # create output specific to this iteration from the two baseline files
   diff /tmp/runLoop.sh.out.before /tmp/runLoop.sh.out.after | cut -c3- > /tmp/runLoop.sh.out.iter

done

