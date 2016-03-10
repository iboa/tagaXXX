#####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################

TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

outputDir=$1

for target in $targetList
do
   echo
   echo processing, collecting files from $target start:`date | cut -c12-20`

   scp $MYLOGIN_ID@$target:/tmp/$TEST_DESCRIPTION* $outputDir
   ssh -l $MYLOGIN_ID $target rm /tmp/$TEST_DESCRIPTION* 2>/dev/null 

   echo processing, collecting files from $target  stop :`date | cut -c12-20`

done

echo
echo $0 : Total File Count: `ls $outputDir | wc -l` Total Line Count: `cat $outputDir/* | wc -l`
echo

