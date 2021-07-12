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

init () {
    stty -F $SERIAL_PORT 9600 cs8 -cstopb -parenb -opost -ixon raw -echo

    if [ $? -ne "0" ]; then
        echo "rs41_dump.sh: failed to open serial port device:" $SERIAL_PORT 1>&2
        exit 1
    fi

    # creating a bidirectional file descriptor for
    # communication with the serial port:

    exec 99<> $SERIAL_PORT

    # test if the radiosonde has the menu enabled
    # by sending a '\r' and checking for a '>'
    # prompt:

    empty_command

    # if the prompt was not obtained, then we 
    # assume the menu mode is disabled and try to
    # enable it:

    if [ "$EMPTY_CMD_RES" != "0" ]; then
        echo "rs41_dump.sh: menu mode disabled. Going to enable it by sending the 'STwsv' string..." 1>&2

        # enable serial commands:

        printf "STwsv" >& $IO_DESC

        # send empty command to let prompt/menu show up:
        empty_command

        # test if menu mode was successfully enabled:

        if [ "$EMPTY_CMD_RES" == "0" ]; then
            echo "rs41_dump.sh: menu mode was successfully enabled!" 1>&2
        else
            echo "rs41_dump.sh: failed to enable menu mode. Aborting." 1>&2

            exit 1
        fi        
    else
        echo "rs41_dump.sh: menu mode is already active." 1>&2
    fi

    # extra '\r' to let the menu show up again and buffer flushed before starting to take readings:

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
        EMPTY_CMD_RES=$?
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

    if [ "$IS_RW" == "1" ]; then
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

        # Let's only print the parameter if it is set:
        if [ -n "$PARAM" ]; then
            echo $param_name","$PARAM","$IS_RW
        fi
    done 
}

print_syntax () {
    echo "rs42_dump.sh"
    echo ""
    echo "Dumps the configuration data from the Vaisala RS-41 radiosondes to the standard output in CSV format."
    echo ""
    echo "Syntax:"
    echo ""
    echo ""
    echo "rs42_dump.sh [start_val] [end_val] [step]"
    echo ""
    echo "  start_val   - the initial parameter ID (in hex notation) in the scan interval."
    echo "  end_val     - the final parameter ID (in hex notation) in the scan interval."
    echo "  step        - the step between IDs to use."
    echo ""
    echo "Examples:"
    echo ""
    echo " 1. CSV list mode:"
    echo ""
    echo "./rs42_dump.sh 0x10 0x800 0x10"
    echo ""    
    echo " 2. Interval mode:"
    echo ""
    echo "./rs42_dump.sh"

}

if [ "$#" -ge 1 ] && [ "$1" == "--help" ]; then
    print_syntax

    exit 0
fi

init

if [ -z $1 ]; then
    dump_params_based_on_list
else
    if [ "$#" -ne 3 ]; then
        print_syntax

        exit 1
    fi

    dump_params_based_on_interval $1 $2 $3
fi

teardown
