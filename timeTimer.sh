#####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################

START_DATE=`date -Ins`
START_DATE2=$START_DATE
END_DATE=`date -Ins`
./timeDeltaCalc.sh $START_DATE $END_DATE target delta1 0
END_DATE2=`date -Ins`
./timeDeltaCalc.sh $START_DATE2 $END_DATE2 target2 delta2 0



