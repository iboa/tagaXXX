#####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################

TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

thistest=0
thistest=1
if [ $thistest -eq 1 ]; then 
   echo ------------  top `hostname` top $MYIP --------------------------
#   sleep 1
   top -b -n 1 | head -n 5
fi

thistest=1
thistest=0
if [ $thistest -eq 1 ]; then 
   echo ------------  ifconfig `hostname` ifconfig $MYIP --------------------------
#   sleep 1
   ifconfig
fi

thistest=0
thistest=1
if [ $thistest -eq 1 ]; then 
   echo ------------  netstat -ns `hostname` netstat summary $MYIP --------------------------
#   sleep 1
   $TAGA_DIR/netstatSum.sh
fi

thistest=1
thistest=0
if [ $thistest -eq 1 ]; then 
   echo ------------  netstat -ns `hostname` netstat -ns $MYIP --------------------------
#   sleep 1
   netstat -ns
fi

thistest=1
thistest=0
if [ $thistest -eq 1 ]; then 
   echo ------------  netstat -r  \(route\) `hostname` $MYIP ---------------------
#   sleep 1
   netstat -r
fi

