#####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################

TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

# get the md5sum of the targetlist config so we know if it changes
configMd5sum=`md5sum $TAGA_DIR/targetList.sh | cut -d" " -f 1`

# set the flag to enter the loop
let configChanged=1

# loop while config continues to change
while [ $configChanged -eq 1 ]
do

for target in $targetList
do
   # reinit
   let delay=0
   let valid=0
   let trycount=0

   while [ $valid -eq 0 ]
   do

   # resource the config in case the strict flag or other config is modified
   source $TAGA_DIR/config

   # make sure this target is still in the list
   if echo $targetList | grep $target >/dev/null; then
      echo Target is still in the list >/dev/null
   else
      echo Target List has changed, $target no longer valid target.
      break
   fi

   echo
   echo $0 checking $target

   # get the DTS with nanoseconds granularity
   MY_TIME=`date -Ins` 
   TGT_TIME=`ssh -l $MYLOGIN_ID $target date -Ins` 

   # check the ssh return code
   if [ $? -eq 0 ]; then
      # good return code
      echo okay keep going >/dev/null
   else

       let trycount=$trycount+1
       if [ $trycount -ge 10 ] ; then
         echo
         echo "WARNING: "
         echo "WARNING: Unable to obtain system time from $target"
         echo "WARNING: "
         echo
         sleep 3

         if [ $STRICT_TIME_SYNCH -eq 0 ];  then 
           echo "WARNING: "
           echo "WARNING: Continuing without time synch check with $target ....."
           echo "WARNING: "
           echo
           sleep 3
           # break from while loop
           break
         else
           echo NOTE:
           echo "NOTE: Strict Time Synch is Enabled."
           echo "NOTE: To proceed without time synch, set STRICT_TIME_SYNCH  = 0 in config."
           echo NOTE:
           echo
           sleep 3
         fi
       fi

      # bad return code
      echo 
      echo "WARNING: "
      echo "WARNING: Unable to obtain system time from $target"
      echo "WARNING: "
      echo 
      sleep 1
      continue
   fi

   # print the info
   echo $MY_TIME : $MYIP
   echo $TGT_TIME : $target

   # get the meaty part of the string
   MY_TIME2=`echo $MY_TIME | cut -c18-100 | cut -c1-12`
   TGT_TIME2=`echo $TGT_TIME | cut -c18-100 | cut -c1-12`

   # strip commas
   MY_TIME3=`echo $MY_TIME2 | sed -e s/,//g`
   TGT_TIME3=`echo $TGT_TIME2 | sed -e s/,//g`

   # strip leading 0s
   MY_TIME4=`echo $MY_TIME3 | sed -e s/^0//g | sed -e s/^0//g | sed -e s/^0//g | sed -e s/^0//g | sed -e s/^0//g`
   TGT_TIME4=`echo $TGT_TIME3 | sed -e s/^0//g | sed -e s/^0//g | sed -e s/^0//g | sed -e s/^0//g | sed -e s/^0//g`
   #TGT_TIME4=`echo $TGT_TIME3 | sed -e s/^0//g`

   # get the delta
   let DELTA=$TGT_TIME4-$MY_TIME4
   let retCode=$?

   # check validity
   if [ $retCode -eq 0 ] ; then
     # check validity
     if [ $DELTA -gt 0 ] ; then 

       # set valid to true
       let valid=1

       # reset try count flag so we don't give false warnings
       let trycount=0

       deltalen=`echo $DELTA | awk '{print length($0)}'`

       if [ $deltalen -eq 1 ] ; then
          duration="(X < 1/100000000 sec)"
          echo WARNING: This is an Anomaly!!
          let delay=60
       elif [ $deltalen -eq 2 ] ; then
          duration="(X < 1/10000000 sec)"
          echo WARNING: This is an Anomaly!!
          let delay=60
       elif [ $deltalen -eq 3 ] ; then
          duration="(X < 1/1000000 sec)"
          echo WARNING: This is an Anomaly!!
          let delay=60
       elif [ $deltalen -eq 4 ] ; then
          duration="(X < 1/100000 sec)"
          echo WARNING: This is an Anomaly!!
          let delay=60
       elif [ $deltalen -eq 5 ] ; then
          duration="(X < 1/10000 sec)"
          echo WARNING: This is an Anomaly!!
          let delay=60
       elif [ $deltalen -eq 6 ] ; then
          duration="(X < 1/1000 sec)"
          echo WARNING: This is an Anomaly!!
          let delay=60
       elif [ $deltalen -eq 7 ] ; then
          duration="(X < 1/100 sec)"
          echo WARNING: This is an Anomaly!!
          let delay=60
       elif [ $deltalen -eq 8 ] ; then
          duration="(X < 1/10 sec)"
          echo WARNING: This is an Anomaly!!
          let delay=60
       elif [ $deltalen -eq 9 ] ; then
          duration="(X < 1 sec)"
          MILLISECS=`echo $DELTA | cut -c1-3`
          FRACTIONPART=`echo $DELTA | cut -c4`
          duration="(X > $MILLISECS.$FRACTIONPART msecs) ******* *******" 
          let delay=0
       elif [ $deltalen -eq 10 ] ; then
          duration="(1 sec < X < 10 secs) ********"
          SECS=`echo $DELTA | cut -c1`
          FRACTIONPART=`echo $DELTA | cut -c2`
          duration="(X > $SECS.$FRACTIONPART secs) ******* *******" 
          let delay=1
       else
          duration="(X > 10 secs) ******* *******" 
          SECS=`echo $DELTA | cut -c1-2`
          FRACTIONPART=`echo $DELTA | cut -c3`
          duration="(X > $SECS.$FRACTIONPART secs) ******* *******" 
          let delay=5
       fi
       echo -----------
       echo "$DELTA   Delta: $duration"    Target: $target
       echo -----------
     else
       echo -----------
       echo "Invalid (Negative) Delta  Delta: (Invalid) (Minute boundaries not supported)" 
       echo -----------
     fi
   else
     echo -----------
     echo "Invalid Delta  Delta: (Invalid) (Minute boundaries not supported)" 
     echo -----------
   fi

   # delay if warning condition
   sleep $delay

   let trycount=$trycount+1
   if [ $trycount -ge 10 ] ; then
     echo
     echo "WARNING: "
     echo "WARNING: Unable to obtain system time from $target"
     echo "WARNING: "
     echo
     sleep 3

     if [ $STRICT_TIME_SYNCH -eq 0 ];  then 
       echo "WARNING: "
       echo "WARNING: Continuing without time synch check with $target ....."
       echo "WARNING: "
       echo
       sleep 3
       # break from while loop
       break
     else
       echo NOTE:
       echo "NOTE: Strict Time Synch is Enabled."
       echo "NOTE: To proceed without time synch, set STRICT_TIME_SYNCH  = 0 in config."
       echo NOTE:
       echo
       sleep 3
     fi

   fi

   # resource the config in case the strict flag is modified
   source $TAGA_DIR/config

   # while not valid
   done

done # end targetList

# get the md5sum of the targetlist config so we know if it changes
configMd5sum2=`md5sum $TAGA_DIR/targetList.sh | cut -d" " -f 1`

if [ $configMd5sum == $configMd5sum2 ]; then
  let configChanged=0
fi

# rebaseline our targetlist config (md5sum) for next iteration check
configMd5sum=`md5sum $TAGA_DIR/targetList.sh | cut -d" " -f 1`

done  # end while

