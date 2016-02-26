#####################################################
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

# archive directory processing
if [ $TESTONLY -eq 1 ] ; then
  # use the testing directory for testing
  outputDir=$OUTPUT_DIR/output
fi 
# go to the output Directory for processing
cd $outputDir

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
      else
        # UCAST
        cat /tmp/curcount.txt  | cut -d">" -f 2-      > /tmp/curcount2.txt  # get receivers only
        cat /tmp/curcount2.txt | grep $target2\\\.      > /tmp/curcount.txt   # remove all except target2 rows
        cat /tmp/curcount.txt  | grep "length $MSGLEN" > /tmp/curcount2.txt  # verify length
        cat /tmp/curcount2.txt | wc -l                > /tmp/curcount.txt   # get the count
      fi

      # populate curcount from the curcount.txt file
      let curcount=`cat /tmp/curcount.txt`

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

  echo $row
  echo $row >> $TAGA_DIR/counts.txt
  echo $row >> $TAGA_DIR/countsSends.txt

done

