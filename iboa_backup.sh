#####################################################
# Copyright 2016 IBOA Corp
# All Rights Reserved
#####################################################

BACKUP_DATE=`date +%j%H%M%S`
BACKUP_DIR=~/.iboaBackup/iboaBackup_$BACKUP_DATE
mkdir -p $BACKUP_DIR; cp ~/.bashrc* $BACKUP_DIR
echo IBOA backup: all .bashrc* files written to $BACKUP_DIR

