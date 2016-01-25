TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

# Single Machine Commands
# DO THIS ONE TIME ONLY ON SOURCE MACHINE AND ONLY IF NEEDED
#   ssh-keygen

######################################
######################################
######################################

# DO THIS FOR EACH DEST MACHINE

echo $targetList

for target in $targetList
do
  ssh-copy-id $MYLOGIN_ID@$target
  
  # prep tcpdump (TBD if this is needed)
  #ssh -l $MYLOGIN_ID $target $TAGA_DIR/prep_tcpdump.sh

done

