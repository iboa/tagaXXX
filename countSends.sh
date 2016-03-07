####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################

TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

# get the inputs
outputDir=$1
iter=$2
startTime=$3
startDTG=$4
deltaEpoch=$5

# get the average iteration duration

echo $deltaEpoch
echo $iter
echo averageDuration=$deltaEpoch/$iter

let averageDuration=$deltaEpoch/$iter

# archive directory processing
if [ $TESTONLY -eq 1 ] ; then
  # use the testing directory for testing
  outputDir=$OUTPUT_DIR/output
fi 
# go to the output Directory for processing
cd $outputDir

# add a line break and date to output and counts.txt
echo; echo >> $TAGA_DIR/counts.txt
date; date >> $TAGA_DIR/counts.txt

# add the header
echo ============================ TAGA Iteration:$iter ===========================
echo ============================ TAGA Iteration:$iter =========================== >>  $TAGA_DIR/counts.txt

echo TAGA:iter:$iter avg:$averageDuration secs StartDTG:$startTime $startDTG Test:$TESTTYPE
echo TAGA:iter:$iter avg:$averageDuration secs StartDTG:$startTime $startDTG Test:$TESTTYPE >> $TAGA_DIR/counts.txt
#echo `date` Iter:$iter $averageDuration StartDTG: $startTime $startDTG Test: $TESTTYPE >> $TAGA_DIR/counts.txt

# calculate the aggregate commanded throughput rate
let targetCount=0
for target in $targetList
do
   let targetCount=$targetCount+1
done

let BITS_PER_BYTE=8
let commandedRate=$MSGRATE*$targetCount*$MSGLEN*$BITS_PER_BYTE
let megabitRate=$commandedRate*1000/1000000
let kilobitRate=$commandedRate*1000/1000

#echo kilobitrate: $kilobitRate

# pad target name as necessary to have nice output
let ratelen=`echo $commandedRate | awk '{print length($0)}'`
#echo $ratelen
if [ $ratelen -eq 8 ]; then
  megabitPrint=`echo $megabitRate | cut -c1-2`.`echo $megabitRate | cut -c3-4`
  #kilobitPrint=`echo $kilobitRate `
  let kilobitPrint=$kilobitRate/1000
elif [ $ratelen -eq 7 ]; then
  megabitPrint=`echo $megabitRate | cut -c1`.`echo $megabitRate | cut -c2-4`
  #kilobitPrint=`echo $kilobitRate `
  let kilobitPrint=$kilobitRate/1000
elif [ $ratelen -eq 6 ]; then
  megabitPrint=0.`echo $megabitRate | cut -c1-3`
  #kilobitPrint=`echo $kilobitRate `
  let kilobitPrint=$kilobitRate/1000
elif [ $ratelen -eq 5 ]; then
  megabitPrint=0.0`echo $megabitRate | cut -c1-2`
  kilobitPrint=`echo $kilobitRate | cut -c1-2`.`echo $kilobitRate | cut -c3-4`
elif [ $ratelen -eq 4 ]; then
  megabitPrint=0.00`echo $megabitRate | cut -c1`
  kilobitPrint=`echo $kilobitRate | cut -c1`.`echo $kilobitRate | cut -c2-4`
elif [ $ratelen -eq 3 ]; then
  megabitPrint=0.000
  kilobitPrint=0.`echo $kilobitRate | cut -c1-3`
elif [ $ratelen -eq 2 ]; then
  megabitPrint=0.000
  kilobitPrint=0.0`echo $kilobitRate | cut -c1-2`
else
  megabitPrint=0.000
fi

echo TAGA:Iter:$iter: Commanded Throughput: $commandedRate bps \($kilobitPrint kbps\)  \($megabitPrint mbps\) 
echo TAGA:Iter:$iter: Commanded Throughput: $commandedRate bps \($kilobitPrint kbps\)  \($megabitPrint mbps\) >> $TAGA_DIR/counts.txt


# get Gross Received Count
let grossReceivedCount=0

# Get Multicast Received Counts
if [ $TESTTYPE == "MCAST" ]; then
  for target in $targetList
  do
    HOST=`cat $TAGA_DIR/hostsToIps.txt | grep $target\\\. | cut -d"." -f 5`
    SOURCE_FILE_TAG=$TEST_DESCRIPTION\_$HOST\_*$target\_
    # get our target receive count
    let targetReceivedCount=`cat $SOURCE_FILE_TAG* | grep -v $target | wc -l`
    let grossReceivedCount=$grossReceivedCount+$targetReceivedCount
  done
else
  # Get Unicast Received Counts
  for target in $targetList
  do
    HOST=`cat $TAGA_DIR/hostsToIps.txt | grep $target\\\. | cut -d"." -f 5`
    SOURCE_FILE_TAG=$TEST_DESCRIPTION\_$HOST\_*$target\_
    # get receivers only and only our target
    let targetReceivedCount=`cat $SOURCE_FILE_TAG* | cut -d">" -f 2- | grep $target | wc -l`
    let grossReceivedCount=$grossReceivedCount+$targetReceivedCount
  done
fi


#####################################################
# Build the Top Line of the File
#####################################################
#####################################################

# calculate the expected line count
let expectedCount=$MSGCOUNT
let expectedCount2=0

for target in $targetList
do
   # count the nodes we send our message to
   # check the test type
   # if UCAST, we send a message to each node, except ourself
   for target2 in $targetList
   do
     if [ $target2 != $MYIP ]; then
       let expectedCount2=$expectedCount2+1
     fi
   done
done

let expectedCount=$expectedCount*$expectedCount2

let numerator=$grossReceivedCount
let printCount=$numerator
let numerator=$numerator*10000; let denominator=$expectedCount
let percent=$numerator/$denominator 
let checkValue=$numerator/10000 
if [ $checkValue -eq $denominator ]; then
  percent="100.00"
elif [ $checkValue -gt $denominator ]; then
  percent=`echo $percent | cut -c1-3`.`echo $percent | cut -c4-5`
else
  percent=`echo $percent | cut -c1-2`.`echo $percent | cut -c3-4`
  if [ $percent == "0." ]; then
     percent="0.0"
  fi
fi

# write blank line to output; write blank line to counts.txt file
echo; echo >> $TAGA_DIR/counts.txt

# build up the buffer
buffer1="TAGA:Iter:$iter: Tot Files:`ls $outputDir | wc -l` Rec'd Count:$printCount / $expectedCount exp msgs "
# pad the buffer
buflen=`echo $buffer1 | awk '{print length($0)}'`
let ROW_SIZE=66
let ROW_SIZE=64
let padlen=$ROW_SIZE-$buflen
# add the padding
let i=$padlen
while [ $i -gt 0 ];
do
  buffer1="$buffer1."
  let i=$i-1
done
# add the percent at the end of the buffer
buffer2="$buffer1 ($percent%)"

# write buffer line to output; write buffer line to counts.txt file
echo $buffer2 ; echo $buffer2 >> $TAGA_DIR/counts.txt


#####################################################
# Build the Second Line of the File
#####################################################
#####################################################
# calculate the expected line count
let expectedCount=$MSGCOUNT
let expectedCount2=0
let expectedCount3=0
for target in $targetList
do
   # count the nodes we send our message to
   # check the test type

   # if UCAST, we send a message to each node, except ourself
   # but this expected message count is even valid for the MCAST 
   # since we count on the receive side
   for target2 in $targetList
   do
      if [ $target2 != $MYIP ]; then
         let expectedCount2=$expectedCount2+1
      fi
   done

   # accumulate the mcast sends counts
   if [ $TESTTYPE == "MCAST" ]; then
      # if MCAST, we send only one message per all nodes
      let expectedCount3=$expectedCount3+1
   fi

done

if [ $TESTTYPE == "MCAST" ]; then
   let expectedCount=$expectedCount*1
else
   let expectedCount=$expectedCount*2
fi

if [ $TESTTYPE == "MCAST" ]; then
   let expectedCount=$expectedCount*$expectedCount2
   let expectedCount3=$expectedCount3*$MSGCOUNT
   let expectedCount=$expectedCount+$expectedCount3
else
   let expectedCount=$expectedCount*$expectedCount2
fi

let numerator=`cat $outputDir/* | wc -l`
let numerator=$numerator*10000
let denominator=$expectedCount
let percent=$numerator/$denominator 

let checkValue=$numerator/10000 
if [ $checkValue -eq $denominator ]; then
  percent="100.00"
elif [ $checkValue -gt $denominator ]; then
  percent=`echo $percent | cut -c1-3`.`echo $percent | cut -c4-5`
else
  percent=`echo $percent | cut -c1-2`.`echo $percent | cut -c3-4`
  if [ $percent == "0." ]; then
     percent="0.0"
  fi
fi

# write blank line to output; write blank line to counts.txt file
#echo; echo >> $TAGA_DIR/counts.txt

# write to output
#echo TAGA:Iter:$iter: Tot Files:`ls $outputDir | wc -l` Total Count:`cat $outputDir/* | wc -l` / $expectedCount exp msgs \($percent%\)
# write to counts.txt file
#echo TAGA:Iter:$iter: Tot Files:`ls $outputDir | wc -l` Total Count:`cat $outputDir/* | wc -l` / $expectedCount exp msgs \($percent%\) >> $TAGA_DIR/counts.txt

# build up the buffer
printCount=`cat $outputDir/* | wc -l`
buffer1="TAGA:Iter:$iter: Tot Files:`ls $outputDir | wc -l` Total Count:$printCount / $expectedCount exp msgs "
# pad the buffer
buflen=`echo $buffer1 | awk '{print length($0)}'`
let ROW_SIZE=66
let ROW_SIZE=64
let padlen=$ROW_SIZE-$buflen
# add the padding
let i=$padlen
while [ $i -gt 0 ];
do
  buffer1="$buffer1."
  let i=$i-1
done
# add the percent at the end of the buffer
buffer2="$buffer1 ($percent%)"

# write buffer line to output; write buffer line to counts.txt file
echo $buffer2 ; echo $buffer2 >> $TAGA_DIR/counts.txt




##################################################################
# PRINT HEADER ROWS
##################################################################
$TAGA_DIR/printSendersHeader.sh "SENDERS" $iter $startTime $startDTG

###################
# MAIN COUNT/SORT
###################

curcount="xxxx"

for target in $targetList
do

  # build Row output

  # init the row cumulative
  let row_cumulative=0

  # pad target name as necessary to have nice output
  tgtlen=`echo $target | awk '{print length($0)}'`

  if [ $tgtlen -eq 17 ] ; then
    row=$target\ 
  elif [ $tgtlen -eq 16 ] ; then
    row=$target\. 
  elif [ $tgtlen -eq 15 ] ; then
    row=$target\.. 
  elif [ $tgtlen -eq 14 ] ; then
    row=$target\... 
  elif [ $tgtlen -eq 13 ] ; then
    row=$target\.... 
  elif [ $tgtlen -eq 12 ] ; then
    row=$target\..... 
  elif [ $tgtlen -eq 11 ] ; then
    row=$target\..... 
  elif [ $tgtlen -eq 10 ] ; then
    row=$target\...... 
  else
    row=$target\....... 
  fi

  # get the sent count for (to) this target
  for target2 in $targetList
  do
    if [ $target == $target2 ] ; then
      # skip self
      curcount="xxxx"
    else

      # else get the count for this target
      HOST=`cat $TAGA_DIR/hostsToIps.txt | grep $target\\\. | cut -d"." -f 5`
      SOURCE_FILE_TAG=$TEST_DESCRIPTION\_$HOST\_*$target\_

      # make sure we are starting with empty files
      rm /tmp/curcount.txt /tmp/curcount2.txt 2>/dev/null
      touch /tmp/curcount.txt /tmp/curcount2.txt
      
      # write to the curcount.txt file
      cat $SOURCE_FILE_TAG* | grep $target\\\. > /tmp/curcount.txt 2>/dev/null

      # mcast or ucast? 
      if [ $TESTTYPE == "MCAST" ]; then
        # MCAST
        target2=$MYMCAST_ADDR
        cat /tmp/curcount.txt  | grep $target2\. | grep $target.$SOURCEPORT > /tmp/curcount2.txt # filter
        cat /tmp/curcount2.txt  | grep "length $MSGLEN" > /tmp/curcount.txt  # verify length
        cat /tmp/curcount.txt  > /tmp/curcount2.txt   # copy the output to temp file curcount2.txt
        cat /tmp/curcount2.txt | wc -l                > /tmp/curcount.txt   # get the count
      elif [ $TESTTYPE == "UCAST_TCP" ]; then
        # UCAST_TCP
        # Note, this UCAST_TCP case is currently the same as the UCAST_UDP case below
        # Note, if this UCAST_TCP case requires special update in the future, similar
        # changes may require a similar block update in the countReceives.sh file
        cat /tmp/curcount.txt  | cut -d">" -f 2-      > /tmp/curcount2.txt  # get receivers only
        cat /tmp/curcount2.txt | grep $target2\\\.      > /tmp/curcount.txt   # remove all except target2 rows
        cat /tmp/curcount.txt  | grep "length $MSGLEN" > /tmp/curcount2.txt  # verify length
        cat /tmp/curcount2.txt | wc -l                > /tmp/curcount.txt   # get the count
      else
        # UCAST_UDP
        cat /tmp/curcount.txt  | cut -d">" -f 2-      > /tmp/curcount2.txt  # get receivers only
        cat /tmp/curcount2.txt | grep $target2\\\.      > /tmp/curcount.txt   # remove all except target2 rows
        cat /tmp/curcount.txt  | grep "length $MSGLEN" > /tmp/curcount2.txt  # verify length
        cat /tmp/curcount2.txt | wc -l                > /tmp/curcount.txt   # get the count
      fi

      # populate curcount from the curcount.txt file
      let curcount=`cat /tmp/curcount.txt`

      # add this count to the cumulative
      let row_cumulative=$row_cumulative+$curcount

      # pad as necessary
      let mycount=$curcount
      if [ $mycount -lt 10 ] ; then
        # pad
        echo 000$curcount > /dev/null
        curcount=000$curcount
      elif [ $mycount -lt 100 ] ; then
        # pad
        echo 00$curcount > /dev/null
        curcount=00$curcount
      elif [ $mycount -lt 1000 ] ; then
        # pad
        echo 0$curcount > /dev/null
        curcount=0$curcount
      else
        # no pad needed
        echo $node > /dev/null
      fi

      if [ -f  $SOURCE_FILE_TAG*$target_ ] ; then
        echo file exists! >/dev/null
      else
        echo file NO exists! >/dev/null
        curcount="----"
      fi 2>/dev/null
    fi 
    
    # append count to the row string
    row="$row  $curcount"

  done # continue to next target

  row="$row"" "

  # dlm temp
  let ROW_SIZE=66
  let rowlen=`echo $row | awk '{print length($0)}'`
#  echo $rowlen
  let padlen=$ROW_SIZE-$rowlen

  # add the padding
  let i=$padlen
  while [ $i -gt 0 ];
  do
     #row="$row"" "
     row="$row."
     let i=$i-1
  done


  # get the row padding
  let valuelen=`echo $row_cumulative | awk '{print length($0)}'`
  # pad it
  if [ $valuelen -eq 3 ] ; then
     row_cumulative=0$row_cumulative
  elif [ $valuelen -eq 2 ] ; then
     row_cumulative=00$row_cumulative
  elif [ $valuelen -eq 1 ] ; then
     row_cumulative=000$row_cumulative
  else
     echo nothing to pad >/dev/null
  fi

  # append the cumulative row total to the row output
  row="$row $row_cumulative"

  echo $row
  echo $row >> $TAGA_DIR/counts.txt
  echo $row >> $TAGA_DIR/countsSends.txt

done

