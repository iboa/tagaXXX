#!/bin/bash

TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

echo $MYIP: $0 executing at `date`

#####################################
# SIMULATE INIT FUNCTION
#####################################

# cleanup old processes, resources, sockets and such
rm $OLDSOCKPROCFILE1 2>/dev/null 
rm $OLDSOCKPROCFILE2 2>/dev/null

