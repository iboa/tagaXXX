
TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

for target in $targetList
do
   echo processing $target

   ssh -l $MYLOGIN_ID $target $TAGA_DIR/simulate.sh       <$TAGA_DIR/passwd.txt &
   ssh -l $MYLOGIN_ID $target $TAGA_DIR/simulatePubSub.sh <$TAGA_DIR/passwd.txt &
   ssh -l $MYLOGIN_ID $target $TAGA_DIR/simulateXXX.sh    <$TAGA_DIR/passwd.txt &
   ssh -l $MYLOGIN_ID $target $TAGA_DIR/simulateSIM1.sh   <$TAGA_DIR/passwd.txt &

   # run traffic unless simulation only flag is set
   if [ $SIMULATION_ONLY -eq 0 ]; then
      ssh -l $MYLOGIN_ID $target $TAGA_DIR/tcpdump.sh & 
      ssh -l $MYLOGIN_ID $target $TAGA_DIR/mgen.sh &
   fi

done



