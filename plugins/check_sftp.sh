#!/usr/bin/env bash

#exec >> /tmp/check_tidal_sftp.log 2>&1

#set -x
HOST=host
USER=user
PASS=pass
REMOTEDIR=/
SFTP_COMMANDS=/tmp/check.sftp
stat_file=/tmp/check_sftp_${HOST}

RC=0
  #prepare commands
  test -f $SFTP_COMMANDS && rm -f $SFTP_COMMANDS;
  echo "cd $REMOTEDIR/" >> $SFTP_COMMANDS
  echo "bye" >> $SFTP_COMMANDS

  echo "$PASS" | $(dirname $0)/sshaskpass.sh sftp -oNumberOfPasswordPrompts=1 -oBatchMode=no -b ${SFTP_COMMANDS} "$USER@$HOST" > ${stat_file} 2>&1
  RC=$?
  if [ ! "$RC" -eq 0 ];then
        echo "CRITICAL: sftp $USER@$HOST failed: $( cat ${stat_file} )"
        RC=2
  else
        echo "OK: sftp $USER@$HOST"
  fi

exit $RC;
