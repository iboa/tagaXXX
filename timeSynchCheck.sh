
TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

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

   echo
   echo $0 checking $target

   # get the DTS with nanoseconds granularity
   MY_TIME=`date -Ins` 
   TGT_TIME=`ssh -l $MYLOGIN_ID $target date -Ins` 

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

       let valid=1

       deltalen=`echo $DELTA | awk '{print length($0)}'`

       if [ $deltalen -eq 8 ] ; then
          duration="(X < 1/10 sec)"
          let delay=600
       elif [ $deltalen -eq 9 ] ; then
          duration="(X < 1 sec)"
          let delay=0
       elif [ $deltalen -eq 10 ] ; then
          duration="(1 sec < X < 10 secs) ********"
          let delay=1
       else
          duration="(X > 10 secs) ******* *******" 
          let delay=5
       fi
       echo -----------
       #echo $MY_TIME3
       echo $TGT_TIME3 - $MY_TIME3 = $DELTA
       echo -----------
       echo "$DELTA   Delta: $duration"    Target: $target
       echo -----------
     else
       echo -----------
       echo "Invalid (Negative) Delta" 
       echo -----------
       echo "Invalid (Negative) Delta  Delta: (Invalid) (Minute boundaries not supported)" 
       echo -----------
     fi
   else
     echo -----------
     echo Invalid Delta 
     echo -----------
     echo "Invalid Delta  Delta: (Invalid) (Minute boundaries not supported)" 
     echo -----------
   fi

   # delay if warning condition
   sleep $delay

   let trycount=$trycount+1

   if [ $trycount -ge 10 ] ; then
     echo "WARNING: "
     echo "WARNING: Unable to obtain system time from $target"
     echo "WARNING: "
     sleep 3

     if [ $STRICT_TIME_SYNCH -eq 0 ];  then 
       echo "WARNING: "
       echo "WARNING: Continuing without time synch check with $target ....."
       echo "WARNING: "
       sleep 3
       # break from while loop
       break
     else
       echo "WARNING: "
       echo "WARNING: Unable to obtain system time from $target"
       echo "WARNING: "
       echo
       echo "NOTE: Strict Time Synch is Enabled."
       echo "NOTE: To proceed without time synch, set STRICT_TIME_SYNCH  = 0 in config."
       echo; echo; 
       sleep 3
     fi

   fi

   # resource the config in case the strict flag is modified
   source $TAGA_DIR/config

   # while not valid
   done

done
echo

