
TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

##################################################################
# MAIN
##################################################################

# start with fresh file
rm $TAGA_DIR/hostsToIps.txt 2>/dev/null
rm $TAGA_DIR/hostList.txt 2>/dev/null

# build the hostList from the targetList
for target in $targetList
do
   echo $target 
   targethostname=`ssh -l $MYLOGIN_ID $target hostname` 
   echo $target $targethostname
   echo $targethostname >> /$TAGA_DIR/hostList.txt
   echo $target $targethostname >> /$TAGA_DIR/hostsToIps.txt

done

exit


