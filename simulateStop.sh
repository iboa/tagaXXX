#!/bin/bash

TAGA_DIR=~/scripts/taga
source $TAGA_DIR/config

#echo $0 executing at `date`

################################################3
# MAIN STOP 
################################################3

# One Time / Single Operation Kill Invocations

# Kill xxx_xxx
PS_SEARCH_STR="xxx_xxx"
kill `ps -ef | grep $PS_SEARCH_STR | cut -c9-15` 2>/dev/null
# Kill iboa_xxx
PS_SEARCH_STR="iboa_xxx"
kill `ps -ef | grep $PS_SEARCH_STR | cut -c9-15` 2>/dev/null
# Kill iboa_sim1
PS_SEARCH_STR="iboa_sim1"
kill `ps -ef | grep $PS_SEARCH_STR | cut -c9-15` 2>/dev/null


