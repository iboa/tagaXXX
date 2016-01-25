
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

$TAGA_DIR/printReceiversHeader.sh RECEIVERS $iter $startTime $startDTG

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

  # get the received count for (to) this target
  for target2 in $targetList

  do

    if [ $target == $target2 ] ; then
      # skip self
      curcount="xxxx"
    else

      # else get the count for this target

      HOST=`cat $TAGA_DIR/hostsToIps.txt | grep $target2 | cut -d" " -f 2`
      DEST_FILE_TAG=taga_ucast_$HOST\_

      # write to the curcount.txt file
      cat $DEST_FILE_TAG* > /tmp/curcount.txt 2>/dev/null

      # mcast or ucast? 
      if [ $TESTTYPE == "MCAST" ]; then
        # MCAST
        cat /tmp/curcount.txt  | grep "length $MSGLEN" > /tmp/curcount2.txt # verify length
        cat /tmp/curcount2.txt | cut -d">" -f 1       > /tmp/curcount.txt  # get senders only
        #cat /tmp/curcount.txt  | grep -v $target.$SOURCEPORT > /tmp/curcount2.txt # filter on the target (row)
        cat /tmp/curcount.txt  | grep $target\.      > /tmp/curcount2.txt # filter on the target (row)
        cat /tmp/curcount2.txt | wc -l                > /tmp/curcount.txt  # get the count
      else
        # UCAST
        cat /tmp/curcount.txt  | grep "length $MSGLEN" > /tmp/curcount2.txt # verify length
        cat /tmp/curcount2.txt | cut -d">" -f 1       > /tmp/curcount.txt  # get senders only
        cat /tmp/curcount.txt  | grep $target\.      > /tmp/curcount2.txt # filter on the target (row)
        cat /tmp/curcount2.txt | wc -l                > /tmp/curcount.txt  # get the count
      fi

      # populate curcount from the curcount.txt file
      let curcount=`cat /tmp/curcount.txt`

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

      if [ -f  $DEST_FILE_TAG* ] ; then
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
  echo $row >> $TAGA_DIR/countsReceives.txt


done

echo

