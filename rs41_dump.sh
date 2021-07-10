#!/bin/bash

#  
#  Simple script for dumping the parameters of the
#  Vaisala RS41 radiosondes.
#
#  (C) 2021 Luis Teixeira - teixeluis_at_gmail.com
#  

SERIAL_PORT=/dev/ttyUSB0
IO_DESC=99
PARAM_FILE=rs41_params.csv

init () {
    stty -F $SERIAL_PORT 9600 cs8 -cstopb -parenb -opost -ixon raw

    # creating a bidirectional file descriptor for
    # communication with the serial port:

    exec 99<> $SERIAL_PORT

    # enable serial commands

    #printf "STwsv" > $SERIAL_PORT 
}

teardown () {
    # close the file descriptor:

    exec 99<&-
}

read_parameter () {

    printf "P%s\r" $1 >& $IO_DESC

    while read -t 0.5 -d '>' answer
    do
        MATCH=$(echo $answer|grep -o "Value.*$")
        if [ -n "$MATCH" ]; then
            PARAM=$(echo $MATCH|sed -e "s/Value //g")
        fi
    done <& $IO_DESC

    # In order to deal with writeable parameters that expect a carriage return:
    printf "\r" >& $IO_DESC

    while read -t 0.5 -d '>' answer; do
        true 
    done <& $IO_DESC
}

sonde_lifetime_delta_calc () {
    echo "Sending parameter to be read: "

    read_parameter 480

    INIT_TIME=$(date +%s)
    INIT_PARAM=$PARAM

    echo "Parameter value before: " $PARAM

    sleep 40

    read_parameter 480

    FINAL_TIME=$(date +%s)
    FINAL_PARAM=$PARAM

    echo "Parameter value after: " $PARAM

    echo "Time lapse: " $(($FINAL_TIME - $INIT_TIME))
    echo "Param lapse: " $(($FINAL_PARAM - $INIT_PARAM))
}

dump_params_based_on_list () {
    echo "param_name,param_value"

    {
        # skip the header:

        read
        
        while IFS=',', read -r param_name description
        do
            read_parameter $param_name
            echo $param_name","$PARAM
        done 
    } < $PARAM_FILE
}

init
dump_params_based_on_list
teardown
