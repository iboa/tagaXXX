#####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################

TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

NEW_LOCATION=/tmp/iboa
NEW_LOCATION_REPLACE_STRING="\\/tmp\\/iboa"

mkdir -p $NEW_LOCATION

for file in *.sh #config
do
  echo $file
  #cat $file | sed s/~\\/scripts\\/taga/~\\/scripts\\/taga/g > $NEW_LOCATION/$file
  cat $file | sed s/~\\/scripts\\/taga/$NEW_LOCATION_REPLACE_STRING/g > $NEW_LOCATION/$file
done

for file in $NEW_LOCATION/*.sh
do
   echo $file
   sudo chmod 755 $file
   diff $file `basename $file`
done

# copy the non-script files
others="config *.template"
cp $others $NEW_LOCATION

# change to the new location
cd $NEW_LOCATION
pwd
#ls -lrt

