
TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

outputDir=output_`date +%j%H%M%S` 
mkdir -p $outputDir

for target in $targetList
do
   echo
   echo processing $target
   ssh -l $MYLOGIN_ID $target hostname
   ssh -l $MYLOGIN_ID $target date
done
echo


