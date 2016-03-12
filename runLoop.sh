#####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################

TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

# basic sanity check, to ensure password updated etc
./basicSanityCheck.sh
if [ $? -eq 255 ]; then
  echo Basic Sanith Check Failed - see warning above - $0 Exiting...
  echo
  exit 255
fi

START_STATS=`./adminstats.sh` 
let TX_STATS=`./adminstats.sh TXonly`
let RX_STATS=`./adminstats.sh RXonly`
let START_TX_STATS=$TX_STATS
let START_RX_STATS=$RX_STATS


#########################################
# Update the MASTER entry in the config
#########################################
# strip old MASTER entries and blank lines at end of file
cat $TAGA_DIR/config | sed -e s/^MASTER=.*$//g |     \
      sed -e :a -e '/./,$!d;/^\n*$/{$d;N;;};/\n$/ba' \
           > $TAGA_DIR/tmp.config
# move temp to config
mv $TAGA_DIR/tmp.config $TAGA_DIR/config
# Update the MASTER entry in the config
echo MASTER=$MYIP >> $TAGA_DIR/config
#########################################
# DONE Update the MASTER entry in the config
#########################################

# set the flag in the flag file
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
#sleep 1

# probe if enabled
if [ $PROBE_ENABLED -eq 1 ]; then
  ./probe.sh
fi

# get ping times if enabled
if [ $PING_TIME_CHECK_ENABLED -eq 1 ]; then
  ./pingTimes.sh
fi
#sleep 1

# get resource usage if enabled
if [ $RESOURCE_MON_ENABLED -eq 1 ]; then
  ./wrapResourceUsage.sh
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
# 10 mar 2016, eliminate the synch due to ssh hiccups
#./synch.sh

let iter=0
let k=0
startTime="`date +%T`"
startDTG="`date`"
startEpoch=`date +%s`

# five iterations to converge
let beforeLastLastLastAvgDelta=0
let beforeLastLastAvgDelta=0
let beforeLastAvgDelta=0
let lastAvgDelta=0
let currentAvgDelta=0

let lastEpoch=0

LAST_CONVERGED="Not Yet Converged"

printableDeltaCum=""
printableAverageDeltaCum=""

while true
do

   let k=$k+1

   # check time synch if enabled
   if [ $TIME_SYNCH_CHECK_ENABLED -eq 1 ]; then
     ./timeSynchCheck.sh
   fi
   #sleep 1

   # probe if enabled
   if [ $PROBE_ENABLED -eq 1 ]; then
     ./probe.sh
   fi

   # get ping times if enabled
   if [ $PING_TIME_CHECK_ENABLED -eq 1 ]; then
     ./pingTimes.sh
   fi
   #sleep 1

   # get resource usage if enabled
   if [ $RESOURCE_MON_ENABLED -eq 1 ]; then
      let mod=$k%$RESOURCE_DISPLAY_MODULUS
      if [ $mod -eq 0 ] ; then
        echo k:$k
        ./wrapResourceUsage.sh
      fi
   fi
   #sleep 1

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

   while [ $iter -ge $MAX_ITERATIONS ] 
   do
      # refresh config in case it has changed
      source $TAGA_DIR/config
      echo
      echo `date` Max Iterations \($iter\) Reached - Disabling ............
      sleep 5
   done

   if [ $STEPWISE_ITERATIONS -eq 1 ]; then
      echo; echo INFO: Step-wise iterations configured...
      echo `date` Iterations \($iter\) Reached - Waiting confirmation to proceed
      echo Enter any key to proceed...
      read input 
   fi

   # Increment the iterator
   let iter=$iter+1

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
   #sleep $SERVER_INIT_DELAY
   let i=$SERVER_INIT_DELAY/2
   while [ $i -gt 0 ]; 
   do
      let i=$i-1
      echo Servers Initializing.... $i
      sleep 2
   done

   #for i in 1 2 3 4 5 6 # 7 8 9 10 11
   #do
   #   let ticker=6-$i
   #   echo Servers Initializing.... $ticker
   #   sleep 2
   #done
   #sleep 2


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

   # run the variable test
   echo Executing variable test..... $VARIABLE_TEST
   ./$VARIABLE_TEST

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
 
   #sleep 5
   sleep 1

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

   currentEpoch=`date +%s`

   let currentDelta=$currentEpoch-$lastEpoch
   let lastEpoch=$currentEpoch
   let deltaEpoch=$currentEpoch-$startEpoch

   # special handling for iteration 1
   if [ $iter -eq 1 ]; then
      # use the delta epoch instead of current delta
      #printableDeltaCum="$printableDeltaCum $deltaEpoch"
      printableDeltaCum="$printableDeltaCum 00"
      #printableAverageDeltaCum="$printableAverageDeltaCum $currentAvgDelta"
      printableAverageDeltaCum="$printableAverageDeltaCum 00"
   else 
      printableDeltaCum="$printableDeltaCum $currentDelta"
      printableAverageDeltaCum="$printableAverageDeltaCum $currentAvgDelta"
   fi


   #############################################################
   # create the log dir
   #############################################################
   mkdir -p $LOG_DIR

   #############################################################
   # Print to the Delta Cumlative Log File
   #############################################################

   # special handling for iteration 1
   #if [ $iter -eq 1 ]; then
   #  echo $printableAverageDeltaCum
   #  echo $printableAverageDeltaCum > /tmp/deltaCum.out
   #  # make the log dir
   #  echo $printableAverageDeltaCum > $LOG_DIR/deltaCum.out
   #  echo $printableAverageDeltaCum > $LOG_DIR/_deltaCum.out
   #  echo $printableAverageDeltaCum > $LOG_DIR/d_deltaCum.out
   #else
     echo; echo Convergence:
     echo $printableDeltaCum
     echo $printableDeltaCum > /tmp/deltaCum.out
     # make the log dir
     mkdir -p $LOG_DIR
     echo $printableDeltaCum > $LOG_DIR/deltaCum.out
     echo $printableDeltaCum > $LOG_DIR/_deltaCum.out
     echo $printableDeltaCum > $LOG_DIR/d_deltaCum.out
   #fi

   #############################################################
   # Print to the Average Delta Cumlative Log File
   #############################################################

   echo $printableAverageDeltaCum
   echo
   echo $printableAverageDeltaCum > /tmp/averageDeltaCum.out
   echo $printableAverageDeltaCum > $LOG_DIR/averageDeltaCum.out
   echo $printableAverageDeltaCum > $LOG_DIR/_averageDeltaCum.out
   echo $printableAverageDeltaCum > $LOG_DIR/d_averageDeltaCum.out

   #these are really avgs not deltas
   let beforeLastLastLastAvgDelta=$beforeLastLastAvgDelta
   let beforeLastLastAvgDelta=$beforeLastAvgDelta
   let beforeLastAvgDelta=$lastAvgDelta
   let lastAvgDelta=$currentAvgDelta
   let currentAvgDelta=$deltaEpoch/$iter

   # add if converged check here

   if [ $beforeLastLastLastAvgDelta -eq $beforeLastLastAvgDelta ] ; then
   if [ $beforeLastLastAvgDelta -eq $beforeLastAvgDelta ] ; then
   if [ $beforeLastAvgDelta -eq $lastAvgDelta ] ; then
      if [ $beforeLastAvgDelta -eq $currentAvgDelta ] ; then
          echo Converged: $currentAvgDelta has converged 
          echo Converged: $currentAvgDelta has converged 
          echo Converged: $currentAvgDelta has converged 
          echo Converged: $currentAvgDelta has converged 
          echo Converged: $currentAvgDelta has converged 
          echo Converged: $currentAvgDelta has converged 
          echo Converged: $currentAvgDelta has converged >> counts.txt
          echo Converged: $currentAvgDelta has converged >> counts.txt
          echo Converged: $currentAvgDelta has converged >> counts.txt
          echo Converged: $currentAvgDelta has converged >> counts.txt
          echo Converged: $currentAvgDelta has converged >> counts.txt
          echo Converged: $currentAvgDelta has converged >> counts.txt

          # store it
          LAST_CONVERGED=$currentAvgDelta

      else
         echo Not Converged marker 1 >/dev/null
      fi
    else
      echo Not Converged marker 2 >/dev/null
   fi
   fi
   fi

   echo LastConverged: $LAST_CONVERGED >> counts.txt
   echo LastConverged: $LAST_CONVERGED >> counts.txt
   echo LastConverged: $LAST_CONVERGED >> counts.txt

   # new header
   echo `date` LastConverged: $LAST_CONVERGED >> counts.txt

   # count and sort and display results matrix
   # note, startDTG must be last param since includes spaces
   ./countSends.sh $outputDir $iter $startTime $currentDelta $deltaEpoch $startDTG
   ./countReceives.sh $outputDir $iter $startTime $startDTG 

   for i in 1 2 3 4 5 6 # 7 8 9 10 11
   do
      let ticker=6-$i
      echo Configuration Change Window: Change Configuration Now... $ticker
      sleep 2
   done
   sleep 2

   CURRENT_STATS=`./adminstats.sh`

   echo
   echo "TAGA:Iter:$iter START STATS:   $START_STATS"
   echo "TAGA:Iter:$iter CURRENT STATS: $CURRENT_STATS"

   let TX_STATS=`./adminstats.sh TXonly`
   let RX_STATS=`./adminstats.sh RXonly`
   let CURRENT_TX_STATS=$TX_STATS
   let CURRENT_RX_STATS=$RX_STATS
   let DELTA_TX_STATS=$CURRENT_TX_STATS-$START_TX_STATS
   let DELTA_RX_STATS=$CURRENT_RX_STATS-$START_RX_STATS

   #echo 0
   #echo $DELTA_TX_STATS
   #echo $DELTA_RX_STATS
   #echo 0b
















































   #echo here
   #echo $DELTA_RX_STATS
   #echo here2

   wordlen=`echo $DELTA_RX_STATS | awk '{print length($0)}'`
   #echo wordlen: $wordlen

   if [ $wordlen -eq 8 ]; then
      let MBytes=$DELTA_RX_STATS*10 # multiply by 10 to get fraction
      let MBytes=$MBytes/1000000
      megabytePrint=`echo $MBytes | cut -c1-2`.`echo $MBytes | cut -c3`
      echo "TAGA:Iter:$iter DELTA_RX_STATS:      $DELTA_RX_STATS ($megabytePrint MB RX)"
   elif [ $wordlen -eq 7 ]; then
      let MBytes=$DELTA_RX_STATS*10 # multiply by 10 to get fraction
      let MBytes=$MBytes/1000000
      megabytePrint=`echo $MBytes | cut -c1`.`echo $MBytes | cut -c2`
      echo "TAGA:Iter:$iter DELTA_RX_STATS:      $DELTA_RX_STATS ($megabytePrint MB RX)"
   elif [ $wordlen -eq 6 ]; then
      let KBytes=$DELTA_RX_STATS*10 # multiply by 10 to get fraction
      let KBytes=$KBytes/1000
      kilobytePrint=`echo $KBytes | cut -c1-3`.`echo $KBytes | cut -c4`
      echo "TAGA:Iter:$iter DELTA_RX_STATS:      $DELTA_RX_STATS ($kilobytePrint KB RX)"
   elif [ $wordlen -eq 5 ]; then
      let KBytes=$DELTA_RX_STATS*10 # multiply by 10 to get fraction
      let KBytes=$KBytes/1000
      kilobytePrint=`echo $KBytes | cut -c1-2`.`echo $KBytes | cut -c3-4`
      echo "TAGA:Iter:$iter DELTA_RX_STATS:      $DELTA_RX_STATS ($kilobytePrint KB RX)"
   elif [ $wordlen -eq 4 ]; then
      let KBytes=$DELTA_RX_STATS*10 # multiply by 10 to get fraction
      let KBytes=$KBytes/1000
      kilobytePrint=`echo $KBytes | cut -c1`.`echo $KBytes | cut -c2-4`
      echo "TAGA:Iter:$iter DELTA_RX_STATS:      $DELTA_RX_STATS ($kilobytePrint KB RX)"
   else
      echo "TAGA:Iter:$iter DELTA_RX_STATS:      $DELTA_RX_STATS" 
   fi




   wordlen=`echo $DELTA_TX_STATS | awk '{print length($0)}'`
   #echo wordlen: $wordlen

   if [ $wordlen -eq 8 ]; then
      let MBytes=$DELTA_TX_STATS*10 # multiply by 10 to get fraction
      let MBytes=$MBytes/1000000
      megabytePrint=`echo $MBytes | cut -c1-2`.`echo $MBytes | cut -c3`
      echo "TAGA:Iter:$iter DELTA_TX_STATS:      $DELTA_TX_STATS ($megabytePrint MB TX)"
   elif [ $wordlen -eq 7 ]; then
      let MBytes=$DELTA_TX_STATS*10 # multiply by 10 to get fraction
      let MBytes=$MBytes/1000000
      megabytePrint=`echo $MBytes | cut -c1`.`echo $MBytes | cut -c2`
      echo "TAGA:Iter:$iter DELTA_TX_STATS:      $DELTA_TX_STATS ($megabytePrint MB TX)"
   elif [ $wordlen -eq 6 ]; then
      let KBytes=$DELTA_TX_STATS*10 # multiply by 10 to get fraction
      let KBytes=$KBytes/1000
      kilobytePrint=`echo $KBytes | cut -c1-3`.`echo $KBytes | cut -c4`
      echo "TAGA:Iter:$iter DELTA_TX_STATS:      $DELTA_TX_STATS ($kilobytePrint KB TX)"
   elif [ $wordlen -eq 5 ]; then
      let KBytes=$DELTA_TX_STATS*10 # multiply by 10 to get fraction
      let KBytes=$KBytes/1000
      kilobytePrint=`echo $KBytes | cut -c1-2`.`echo $KBytes | cut -c3-4`
      echo "TAGA:Iter:$iter DELTA_TX_STATS:      $DELTA_TX_STATS ($kilobytePrint KB TX)"
   elif [ $wordlen -eq 4 ]; then
      let KBytes=$DELTA_TX_STATS*10 # multiply by 10 to get fraction
      let KBytes=$KBytes/1000
      kilobytePrint=`echo $KBytes | cut -c1`.`echo $KBytes | cut -c2-4`
      echo "TAGA:Iter:$iter DELTA_TX_STATS:      $DELTA_TX_STATS ($kilobytePrint KB TX)"
   else
      echo "TAGA:Iter:$iter DELTA_TX_STATS:      $DELTA_TX_STATS" 
   fi





#   if [ $wordlen -eq 8 ]; then
#      let MBytes=$DELTA_RX_STATS*10 # multiply by 10 to get fraction
#      let MBytes=$MBytes/1000000
#      megabytePrint=`echo $MBytes | cut -c1-2`.`echo $MBytes | cut -c3`
#      echo TAGA:Iter:$iter DELTA_RX_STATS: $DELTA_RX_STATS \($megabytePrint MB\)
#   elif [ $wordlen -eq 7 ]; then
#      let MBytes=$DELTA_RX_STATS*10 # multiply by 10 to get fraction
#      let MBytes=$MBytes/1000000
#      megabytePrint=`echo $MBytes | cut -c1`.`echo $MBytes | cut -c2`
#      echo TAGA:Iter:$iter DELTA_RX_STATS: $DELTA_RX_STATS \($megabytePrint MB\)
#   elif [ $wordlen -eq 6 ]; then
#      let KBytes=$DELTA_RX_STATS*10 # multiply by 10 to get fraction
#      let KBytes=$KBytes/1000
#      kilobytePrint=`echo $KBytes | cut -c1-3`.`echo $KBytes | cut -c4`
#      echo TAGA:Iter:$iter DELTA_RX_STATS: $DELTA_RX_STATS \($kilobytePrint KB\)
#   elif [ $wordlen -eq 5 ]; then
#      let KBytes=$DELTA_RX_STATS*10 # multiply by 10 to get fraction
#      let KBytes=$KBytes/1000
#      kilobytePrint=`echo $KBytes | cut -c1-2`.`echo $KBytes | cut -c3-4`
#      echo TAGA:Iter:$iter DELTA_RX_STATS: $DELTA_RX_STATS \($kilobytePrint KB\)
#   elif [ $wordlen -eq 4 ]; then
#      let KBytes=$DELTA_RX_STATS*10 # multiply by 10 to get fraction
#      let KBytes=$KBytes/1000
#      kilobytePrint=`echo $KBytes | cut -c1`.`echo $KBytes | cut -c2-4`
#   else
#   #   echo 7b
#      echo TAGA:Iter:$iter DELTA_RX_STATS: $DELTA_RX_STATS
#   fi


   let DELTA_RX_STATS_ITER=$DELTA_RX_STATS/$iter

   #echo 10
   #echo $DELTA_RX_STATS_ITER

   wordlen=`echo $DELTA_RX_STATS_ITER | awk '{print length($0)}'`
   #echo DeltaRxStatusIter wordlen: $wordlen
   if [ $wordlen -eq 8 ]; then
      let MBytes=$DELTA_RX_STATS_ITER*10 # multiply by 10 to get fraction
      let MBytes=$MBytes/1000000
      megabytePrint=`echo $MBytes | cut -c1-2`.`echo $MBytes | cut -c3`
      echo TAGA:Iter:$iter DELTA_RX_STATS_ITER: $DELTA_RX_STATS_ITER \($megabytePrint MB RX per Iter\)
   elif [ $wordlen -eq 7 ]; then
      let MBytes=$DELTA_RX_STATS_ITER*10 # multiply by 10 to get fraction
      let MBytes=$MBytes/1000000
      megabytePrint=`echo $MBytes | cut -c1`.`echo $MBytes | cut -c2`
      echo TAGA:Iter:$iter DELTA_RX_STATS_ITER: $DELTA_RX_STATS_ITER \($megabytePrint MB RX per Iter\)
   elif [ $wordlen -eq 6 ]; then
      let KBytes=$DELTA_RX_STATS_ITER*10 # multiply by 10 to get fraction
      let KBytes=$KBytes/1000
      kilobytePrint=`echo $KBytes | cut -c1-3`.`echo $KBytes | cut -c4`
      echo TAGA:Iter:$iter DELTA_RX_STATS_ITER: $DELTA_RX_STATS_ITER \($kilobytePrint KB RX per Iter\)
   elif [ $wordlen -eq 5 ]; then
      let KBytes=$DELTA_RX_STATS_ITER*10 # multiply by 10 to get fraction
      let KBytes=$KBytes/1000
      kilobytePrint=`echo $KBytes | cut -c1-2`.`echo $KBytes | cut -c3-4`
      echo TAGA:Iter:$iter DELTA_RX_STATS_ITER: $DELTA_RX_STATS_ITER \($kilobytePrint KB RX per Iter\)
   elif [ $wordlen -eq 4 ]; then
      let KBytes=$DELTA_RX_STATS_ITER*10 # multiply by 10 to get fraction
      let KBytes=$KBytes/1000
      kilobytePrint=`echo $KBytes | cut -c1`.`echo $KBytes | cut -c2-4`
      echo TAGA:Iter:$iter DELTA_RX_STATS_ITER: $DELTA_RX_STATS_ITER \($kilobytePrint KB RX per Iter\)
   else
   #   echo 7c
      echo TAGA:Iter:$iter DELTA_RX_STATS_ITER: $DELTA_RX_STATS_ITER
   fi










   let DELTA_TX_STATS_ITER=$DELTA_TX_STATS/$iter

   #echo 9
   #echo $DELTA_TX_STATS_ITER

   wordlen=`echo $DELTA_TX_STATS_ITER | awk '{print length($0)}'`
   #echo DeltaTxStatusIter wordlen: $wordlen
   if [ $wordlen -eq 8 ]; then
      let MBytes=$DELTA_TX_STATS_ITER*10 # multiply by 10 to get fraction
      let MBytes=$MBytes/1000000
      megabytePrint=`echo $MBytes | cut -c1-2`.`echo $MBytes | cut -c3`
      echo "TAGA:Iter:$iter DELTA_TX_STATS_ITER: $DELTA_TX_STATS_ITER ($megabytePrint MB TX per Iter)"
   elif [ $wordlen -eq 7 ]; then
      let MBytes=$DELTA_TX_STATS_ITER*10 # multiply by 10 to get fraction
      let MBytes=$MBytes/1000000
      megabytePrint=`echo $MBytes | cut -c1`.`echo $MBytes | cut -c2`
      echo "TAGA:Iter:$iter DELTA_TX_STATS_ITER: $DELTA_TX_STATS_ITER ($megabytePrint MB TX per Iter)"
   elif [ $wordlen -eq 6 ]; then
      let KBytes=$DELTA_TX_STATS_ITER*10 # multiply by 10 to get fraction
      let KBytes=$KBytes/1000
      kilobytePrint=`echo $KBytes | cut -c1-3`.`echo $KBytes | cut -c4`
      echo "TAGA:Iter:$iter DELTA_TX_STATS_ITER: $DELTA_TX_STATS_ITER ($kilobytePrint KB TX per Iter)"
   elif [ $wordlen -eq 5 ]; then
      let KBytes=$DELTA_TX_STATS_ITER*10 # multiply by 10 to get fraction
      let KBytes=$KBytes/1000
      kilobytePrint=`echo $KBytes | cut -c1-2`.`echo $KBytes | cut -c3-4`
      echo "TAGA:Iter:$iter DELTA_TX_STATS_ITER: $DELTA_TX_STATS_ITER ($kilobytePrint KB TX per Iter)"
   elif [ $wordlen -eq 4 ]; then
      let KBytes=$DELTA_TX_STATS_ITER*10 # multiply by 10 to get fraction
      let KBytes=$KBytes/1000
      kilobytePrint=`echo $KBytes | cut -c1`.`echo $KBytes | cut -c2-4`
      echo "TAGA:Iter:$iter DELTA_TX_STATS_ITER: $DELTA_TX_STATS_ITER ($kilobytePrint KB TX per Iter)"
   else
   #   echo 7a
      echo TAGA:Iter:$iter DELTA_TX_STATS_ITER: $DELTA_TX_STATS_ITER
   fi





   sleep 5

   # move output to the archive
   mv $TAGA_DIR/output/output_* $SCRIPTS_DIR/archive 2>/dev/null

   # re-baseline the aggregate log file
   cp /tmp/runLoop.sh.out /tmp/runLoop.sh.out.after

   # create output specific to this iteration from the two baseline files
   diff /tmp/runLoop.sh.out.before /tmp/runLoop.sh.out.after | cut -c3- > /tmp/runLoop.sh.out.iter

done

