#!/usr/bin/env bash

# script that check CA expiring certificates
#
# Copyright (C) 2013 Michal Ajduk <majduk AT gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

CA_BASE_DIR=/etc/ssl
source $CA_BASE_DIR/paths.cnf

#Set Script Name variable
SCRIPT=`basename ${BASH_SOURCE[0]}`
#Set fonts for Help.
NORM=`tput sgr0`
BOLD=`tput bold`
REV=`tput smso`

now=$( date +%s )
DAYS_WARN=30
DAYS_CRIT=7
LEVEL=0
SERVER=0
USERS=0
UNIQ=0

function HELP {
  echo -e \\n"Help documentation for ${BOLD}${SCRIPT}.${NORM}"\\n
  echo -e "${REV}Basic usage:${NORM} ${BOLD}$SCRIPT${NORM}"\\n
  echo "Command line switches are optional. The following switches are recognized."
  echo "${REV}-c CRIT_DAYS${NORM}  --How many days before expiting raise warning. Default is ${BOLD}${DAYS_WARN}${NORM}."
  echo "${REV}-w WARN_DAYS${NORM}  --How many days before expiting raise critical. Default is ${BOLD}${DAYS_CRIT}${NORM}."
  echo "${REV}-s ${NORM}  --Check server certificate."
  echo "${REV}-u ${NORM}  --Check users certificates."
  echo "${REV}-n ${NORM}  --Check only newest valid certificate for each CommonName."
  echo -e "${REV}-h${NORM}  --Displays this help message."\\n
  echo -e "Example: ${BOLD}$SCRIPT -s ${NORM}"\\n
  exit 1
}

NUMARGS=$#
if [ $NUMARGS -eq 0 ]; then
  HELP
fi

while getopts :c:w:sunh FLAG; do
        case $FLAG in
        c)
                DAYS_CRIT=$OPTARG
                ;;
        w)
                DAYS_WARN=$OPTARG
                ;;
        s)
                SERVER=1
                ;;
        u)
                USERS=1
                ;;
        n)
                UNIQ=1
                ;;
        h)
                HELP
                ;;
        \?)
              echo -e \\n"Option -${BOLD}$OPTARG${NORM} not allowed."
              HELP
        esac
done



LOW_CRIT=$(( $DAYS_CRIT*24*3600  ))
LOW_WARN=$(( $DAYS_WARN*24*3600  ))
list=""

if [ "$UNIQ" -eq 1 ];then
        cat $CA_BASE_DIR/private/index.txt | grep '^V' | sort -r | sort -k 5 -u > /tmp/index.tmp
else
        cp $CA_BASE_DIR/private/index.txt /tmp/index.tmp
fi


while read state ts serial1 serial2 name
do
        #v_ts=${ts:0:10}
  ts_str=$( echo $ts | awk '{ print "20" substr($1,1,2) "-" substr($1,3,2) "-" substr($1,5,2) " " substr($1,7,2) ":" substr($1,9,2) }' )
  v_ts=$( date -d "$ts_str" '+%s' )
  ex_date=$( date -d "$ts_str" '+%Y/%m/%d' )
        if [ $state = "V" ]; then
                t_diff=$(( $v_ts - $now ))
                if [[ $t_diff -lt $LOW_CRIT  ]];then
                        if [[ $t_diff -gt 0  ]];then
                                cn=$( echo $name | cut -d"/" -f6 )
                                if [ "$cn" == "CN=$SERVER_DOMAIN" ];then
                                        if [ "$SERVER" -eq 1  ];then
                                        list="$list SERVER:$cn,SN=$serial1,EXP=$ex_date"
                                        if [ $LEVEL -lt 2 ];then
                                                LEVEL=2
                                        fi
                                        fi
                                else
                                        if [ "$USERS" -eq 1  ];then
                                        list="$list $cn,SN=$serial1,EXP=$ex_date"
                                        if [ $LEVEL -lt 2 ];then
                                                LEVEL=2
                                        fi
                                        fi
                                fi
                        fi
                else
                        if [[ $t_diff -lt $LOW_WARN  ]];then
                                cn=$( echo $name | cut -d"/" -f6 )
                                if [ "$cn" == "CN=$SERVER_DOMAIN" ];then
                                        if [ "$SERVER" -eq 1  ];then
                                        list="$list SERVER:$cn,SN=$serial1,EXP=$ex_date"
                                        if [ $LEVEL -lt 1 ];then
                                                LEVEL=1
                                        fi
                                        fi
                                else
                                        if [ "$USERS" -eq 1  ];then
                                        list="$list $cn,SN=$serial1,EXP=$ex_date"
                                        if [ $LEVEL -lt 1 ];then
                                                LEVEL=1
                                        fi
                                        fi
                                fi
                        fi
                fi
        fi
        #date -d "1970-01-01 00:00 $v_ts seconds" +%Y%m%d
done < /tmp/index.tmp

test -f /tmp/index.tmp || rm -f /tmp/index.tmp

if [ -z "$list" ];then
        echo "OAPI CA: no expiring certificates"
        exit $LEVEL
fi

echo "OAPI CA Certificetes expiring: $list"
exit $LEVEL
