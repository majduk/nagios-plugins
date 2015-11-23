#!/usr/bin/env bash

CA_BASE_DIR=/etc/ssl

now=$( date +%s )
DAYS_WARN=30
DAYS_CRIT=7
LEVEL=0

LOW_CRIT=$(( $DAYS_CRIT*24*3600  ))
LOW_WARN=$(( $DAYS_WARN*24*3600  ))

list=""

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
                                list="$list $cn,SN=$serial1,EXP=$ex_date"
                                if [ $LEVEL -lt 2 ];then
                                        LEVEL=2
                                fi
                        fi
                else
                        if [[ $t_diff -lt $LOW_WARN  ]];then
                                cn=$( echo $name | cut -d"/" -f6 )
                                list="$list $cn,SN=$serial1,EXP=$ex_date"
                                if [ $LEVEL -lt 1 ];then
                                        LEVEL=1
                                fi
                        fi
                fi
        fi
        #date -d "1970-01-01 00:00 $v_ts seconds" +%Y%m%d
done < $CA_BASE_DIR/private/index.txt

if [ -z "$list" ];then
        echo "CA: no expiring certificates"
        exit $LEVEL
fi

echo "CA Certificetes expiring: $list"
exit $LEVEL
