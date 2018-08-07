#!/bin/bash


#---------------------------------------------VARIABLES USED--------------------------------------------------------------------------------
#$PROCESS_NAME - pattern or name of the process of server.
#$SCRIPT_COMMAND - script that runs the process as daemon and exits. BY default this is same as process name . Please change it if required.
#$DELAY -  default delay is set at 5 . change if needed.
#$PPORT = Port ID used by the process. (AUTO FILLED BY THIS SCRIPT)
#$PROCESSID- Process ID of the process. (AUTO FILLED BY THIS SCRIPT)
#$PSTATUS - Process status. (AUTO FILLED BY THIS SCRIPT)

#---------------------------------------------METHODS USED--------------------------------------------------------------------------------
#check_kill_start_loop -  checks response code kills and starts again if required.
#get_process_status - Initializes $PSTATUS Variable.
#start_process
#get_process_port - Initializes $PPORT Variable.
#get_process_id - Initializes $PROCESSID Variable.

check_kill_start_loop(){
    for x in {1..4}
    do
        echo "Hitting curl request to check if service is responding"
        HTTP_RESPONSE_CODE=`curl -s -o /dev/null -w "%{http_code}" $PPORT`
        if [ $HTTP_RESPONSE_CODE -eq 200 ]
        then
            logger -e "Process is up and runing successfully."
            echo "Process is Running successfully."
            break
        else
            echo "PROCESS IS NOT RUNNING SUCCESFULLY. RESTARTING.."
        fi
        sudo  kill -9 $PROCESSID 2>/dev/null;
        start_process
        get_process_port
    done;
}
get_process_status(){
    PSTATUS=`ps $PROCESSID |awk 'FNR==2{print $3}'`
    echo "Process status :$PSTATUS"
    logger -e "PRSCRIPT PROCESS STATUS :$PSTATUS"
}
start_process(){
    $SCRIPT_COMMAND 2>/dev/null &
    sleep $DELAY
    PROCESSID=`pgrep "python"`
    echo "Process started with PID=$PROCESSID"
    logger -e "PRSCRIPT PROCESS STARTED WITH PID=$PROCESSID"
}
get_process_port(){
    PPORT=`sudo netstat -ltp | grep $PROCESSID | awk '{print $4}'` 2>/dev/null
    echo "IP:Port number  =  $PPORT"
    logger -e "PRSCRIPT PROCESS PORT=$PPORT"
    
}
get_process_id(){
    PROCESSID=`pgrep -f "$PROCESS_NAME"`
    
}

if [ "$USER" != "root" ]; then
    echo "Please run script as root for proper functioning."
    exit 1
fi

logger -e "PRSCRIPT Started at `date`"
PROCESS_NAME="python -m SimpleHTTPServer"
SCRIPT_COMMAND=$PROCESS_NAME
DELAY=5

# SCRIPT STARTING------
echo "Searching for $PROCESS_NAME process ID"
get_process_id
echo "Process PID=$PROCESSID"
if [ "$PROCESSID" = "" ]; then
    echo "Process not found.Starting it."
    logger -e "PRSCRIPT PROCESS NOT FOUND STARTING IT"
    start_process
fi
echo "Press any key to continue"; read temp;
get_process_status
get_process_port
check_kill_start_loop
echo "Script completed"
logger -e "PRSCRIPT completed at `date`"
#SCRIPT END-------------


