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
READ_TIMEOUT=0.4
MENU_TXT="(E)xit"

START_VAL=$1
END_VAL=$2
STEP=$3

init () {
    stty -F $SERIAL_PORT 9600 cs8 -cstopb -parenb -opost -ixon raw -echo

    # creating a bidirectional file descriptor for
    # communication with the serial port:

    exec 99<> $SERIAL_PORT

    # enable serial commands:

    #printf "STwsv" > $SERIAL_PORT

    # send empty command to let prompt/menu show up:
    empty_command
}

teardown () {
    # close the file descriptor:

    exec 99<&-
}

empty_command () {
    printf "\r" >& $IO_DESC

    while read -t $READ_TIMEOUT -d '>' answer; 
    do
        true
    done <& $IO_DESC
}

read_parameter () {
    PARAM=
    IS_RW=

    # Sent command to access parameter:

    printf "P%s\r" $1 >& $IO_DESC

    while read -t $READ_TIMEOUT -d '>' answer;
    do
        #echo "Answer = " $answer
        MATCH=$(echo $answer|tr '\r' ' '|grep -o "Value.*$")
        #echo "Match = " $MATCH

        if [ -n "$MATCH" ]; then
            PARAM=$(echo $MATCH|sed -e "s/Value //g")
        fi

        echo $answer|tr '\r' ' '|grep $MENU_TXT > /dev/null

        IS_RW=$?
    done <& $IO_DESC

    # When we get a writeable command, we need to send a CR
    # character to skip writing to the parameter:

    if [ $IS_RW -eq "1" ]; then
        empty_command
    fi
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

    echo "param_name,param_value,is_rw"

    {
        # skip the header:

        read
        
        while IFS=',', read -r param_name description
        do
            read_parameter $param_name
            echo $param_name","$PARAM","$IS_RW
        done 
    } < $PARAM_FILE
}

dump_params_based_on_interval () {
    echo "param_name,param_value,is_rw"

    START_INT=$(printf "%d" $1)
    END_INT=$(printf "%d" $2)
    STEP_INT=$(printf "%d" $3)

    for i in $(seq $START_INT $STEP_INT $END_INT)
    do
        param_name=$(printf "%X" $i)
        read_parameter $param_name
        echo $param_name","$PARAM","$IS_RW
    done 
}

init

if [ -z $START_VAL ]; then
    dump_params_based_on_list
else
    if [ "$#" -ne 3 ]; then
        echo "rs42_dump.sh"
        echo ""
        echo "syntax:"
        echo ""
        echo "rs42_dump.sh start_val end_val step"
        echo ""
        echo "Example: "
        echo ""
        echo "./rs42_dump.sh 0x10 0x800 0x10"

        exit 1
    fi

    dump_params_based_on_interval $START_VAL $END_VAL $STEP
fi

teardown
