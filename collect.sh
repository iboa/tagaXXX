
TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

outputDir=$1

for target in $targetList
do
   echo
   echo processing, collecting files from $target start:`date | cut -c12-20`

   scp $MYLOGIN_ID@$target:/tmp/*taga*cast* $outputDir
   ssh -l $MYLOGIN_ID $target rm /tmp/*taga*cast* 

   echo processing, collecting files from $target  stop :`date | cut -c12-20`

done


