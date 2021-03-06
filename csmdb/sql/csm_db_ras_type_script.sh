#!/bin/bash
#================================================================================
#
#    csm_db_ras_type_script.sh
#
#  © Copyright IBM Corporation 2015-2018. All Rights Reserved
#
#    This program is licensed under the terms of the Eclipse Public License
#    v1.0 as published by the Eclipse Foundation and available at
#    http://www.eclipse.org/legal/epl-v10.html
#
#    U.S. Government Users Restricted Rights:  Use, duplication or disclosure
#    restricted by GSA ADP Schedule Contract with IBM Corp.
#
#================================================================================

#================================================================================
#   usage:              ./csm_db_ras_type_script.sh
#   current_version:    01.9
#   create:             11-07-2017
#   last modified:      12-05-2018
#================================================================================

export PGOPTIONS='--client-min-messages=warning'

OPTERR=0
logpath="/var/log/ibm/csm/db"
logname="csm_db_ras_type_script.log"
cd "${BASH_SOURCE%/*}" || exit
#cur_path=`pwd`

#==============================================
# Current user connected---
#==============================================
current_user=`id -u -n`
dbname="csmdb"
db_username="postgres"
csmdb_user="csmdb"
now1=$(date '+%Y-%m-%d %H:%M:%S')

BASENAME=`basename "$0"`

line1_out="------------------------------------------------------------------------------------------------------------------------"
line2_log="------------------------------------------------------------------------------------"
line3_log="---------------------------------------------------------------------------------------------------------------------------"

#==============================================
# Log Message---
#================================================================================
# This checks the existence of the default log directory.
# If the default doesn't exist it will write the log filesto /tmp directory
# The current version will only display results to the screen
#================================================================================

if [ -w "$logpath" ]; then
    logdir="$logpath"
else
    logdir="/tmp"
fi
logfile="${logdir}/${logname}"

#==============================================
# Log Message function
#==============================================

function LogMsg () {
now=$(date '+%Y-%m-%d %H:%M:%S')
echo "$now ($current_user) $1" >> $logfile
}

#================================
# Log messaging intro. header
#================================
echo "-------------------------------------------------------------------------------------"
LogMsg "[Start   ] Welcome to CSM database ras type automation script."
echo "[Start   ] Welcome to CSM database ras type automation script."

#==============================================
# Usage Command Line Functions
#==============================================

function usage () {
echo "================================================================================================="
echo "[Info    ] $BASENAME : Load/Remove data from csm_ras_type table"
echo "[Usage   ] $BASENAME : [OPTION]... [DBNAME]... [CSV_FILE]"
echo "-------------------------------------------------------------------------------------------------"
echo "  Argument               |  DB Name  | Description                                               "
echo "-------------------------|-----------|-----------------------------------------------------------"
echo " -l, --loaddata          | [db_name] | Imports CSV data to csm_ras_type table (appends)          "
echo "                         |           | Live Row Count, Inserts, Updates, Deletes, and Table Size "
echo " -r, --removedata        | [db_name] | Removes all records from the csm_ras_type table           "
echo " -h, --help              |           | help                                                      "
echo "-------------------------|-----------|-----------------------------------------------------------"
echo "[Examples]"
echo "-------------------------------------------------------------------------------------------------"
echo "   $BASENAME -l, --loaddata           [dbname]    | [csv_file_name]                              "
echo "   $BASENAME -r, --removedata         [dbname]    |                                              "
echo "   $BASENAME -r, --removedata         [dbname]    | [csv_file_name]                              "
echo "   $BASENAME -h, --help               [dbname]    |                                              "
echo "================================================================================================="
}

#==============================================
#---Default flags---
#==============================================

loaddata="no"
removedata="no"

#==============================================
# long options to short along with fixed length
#==============================================

reset=true
for arg in "$@"
do
    if [ -n "$reset" ]; then
      unset reset
      set --      # this resets the "$@" array
    fi
    case "$arg" in
        --loaddata)         set -- "$@" -l ;;
        -loaddata)          usage && exit 0 ;;
        --removedata)       set -- "$@" -r ;;
        -removedata)        usage && exit 0 ;;
        --help)             set -- "$@" -h ;;
        -help)              usage && exit 0 ;;
        -l|-r|-h)           set -- "$@" "$arg" ;;
        #-*)                usage && exit 0 ;;
        -*)                 usage
                            LogMsg "[Info    ] Script execution: $BASENAME [NO ARGUMENT]"
                            LogMsg "[Info    ] Wrong arguments were passed in (Please choose appropriate option from usage list -h, --help)"
                            LogMsg "[End     ] Please choose another option"
                            echo "${line3_log}" >> $logfile
                            exit 0 ;;
        # pass through anything else
        *)                  set -- "$@" "$arg" ;;
     esac
 done

 #==============================================
 # now we can drop into the short getopts
 #==============================================
 # Also checks the existence of the file name
 # If file name is not available then an
 # error message will prompt and will be logged.
 #==============================================

 while getopts "lr:h" arg; do
     case ${arg} in
         l)
            #============================================================================
            # Populate Data in the csm_ras_type table
            # (Import from CSV file)
            # probably want to set populate below during conflict checks
            #============================================================================
             
            #----------------------------------------------------------------
            # Check if csv file exists
            #----------------------------------------------------------------

                if [ -z "$3" ]; then
                    echo "[Error   ] Please specify csv file to import"
                    LogMsg "[Error   ] Please specify csv file to import"
                    echo "${line1_out}"
                    echo "${line3_log}" >> $logfile
                    exit 1
                else
                loaddata="yes"
                dbname="$2"
                csv_file_name="$3"
                    if [ ! -f $csv_file_name ]; then
                    #    echo "[Info    ] $3 file exists"
                    #    LogMsg "[Info    ] $3 file exists"
                    #else    
                        echo "[Error   ] File $csv_file_name can not be located or doesn't exist"
                        echo "[Info    ] Please choose another file or check path"
                        LogMsg "[Error   ] Cannot perform action because the $csv_file_name file does not exist. Exiting."
                        echo "${line3_log}" >> $logfile
                        echo "${line1_out}"
                    exit 0
                    fi
                fi
             ;;
         r)
             #============================================================================
             # Remove all data from the csm_ras_type table
             # (Completely removes all data from the table)
             #============================================================================
             removedata="yes"
             dbname=$2
             csv_file_name="$3"
             ;;
         #h|*)
         h)
             #usage && exit 0
             usage
             LogMsg "[Info    ] Script execution: ./csm_db_stats.sh -h, --help"
             LogMsg "[End     ] Help menu query executed"
             echo "${line3_log}" >> $logfile
             exit 0
             ;;
        *)
            #usage && exit 0
            usage
            LogMsg "[Info    ] Script execution: $BASENAME [NO ARGUMENT]"
            LogMsg "[Info    ] Wrong arguments were passed in (Please choose appropriate option from usage list -h, --help)"
            LogMsg "[End     ] Please choose another option"
            echo "${line3_log}" >> $logfile
            exit 0
            ;;
    esac
done

#==============================================
# Built in checks
# Checks to see if no arguments are passed in
#==============================================

 if [ $# -eq 0 ]; then
     #usage && exit 0
     usage
     LogMsg "[Info    ] Script execution: $BASENAME [NO ARGUMENT]"
     LogMsg "[Info    ] Wrong arguments were passed in (Please choose appropriate option from usage list -h, --help)"
     LogMsg "[End     ] Please choose another option"
     echo "${line3_log}" >> $logfile
     exit 0
 fi

#=================================================
# Check if postgresql exists already and root user
#=================================================
string1="$now1 ($current_user) [Info    ] DB Users:"
    psql -U $db_username -t -c '\du' | cut -d \| -f 1 | grep -qw root
        if [ $? -ne 0 ]; then
            db_user_query=`psql -U $db_username -q -A -t -P format=wrapped <<EOF
            \set ON_ERROR_STOP true
            select string_agg(usename,' | ') from pg_user;
EOF`
            echo "$string1 $db_user_query" | sed "s/.\{60\}|/&\n$string1 /g" >> $logfile
            echo "[Error   ] Postgresql may not be configured correctly. Please check configuration settings."
            LogMsg "[Error   ] Postgresql may not be configured correctly. Please check configuration settings."
            echo "${line1_out}"
            echo "${line3_log}" >> $logfile
            exit 0
        fi

#=================================================
# Check if postgresql exists already and DB name
#=================================================
string2="$now1 ($current_user) [Info    ] DB Names:"
    psql -lqt | cut -d \| -f 1 | grep -qw $dbname 2>>/dev/null
        if [ $? -eq 0 ]; then       #<------------This is the error return code
            db_query=`psql -U $db_username -q -A -t -P format=wrapped <<EOF
            \set ON_ERROR_STOP true
            select string_agg(datname,' | ') from pg_database;
EOF`
            echo "$string2 $db_query" | sed "s/.\{60\}|/&\n$string2 /g" >> $logfile
            LogMsg "[Info    ] PostgreSQL is installed"
        else
            echo "${line1_out}"
            echo "[Error   ] PostgreSQL may not be installed or DB: $dbname may not exist."
            echo "[Info    ] Please check configuration settings or psql -l"
            echo "${line1_out}"
            LogMsg "[Error   ] PostgreSQL may not be installed or DB $dbname may not exist."
            LogMsg "[Info    ] Please check configuration settings or psql -l"
            echo "${line3_log}" >> $logfile
            exit 1
        fi

#======================================
# Check if database exists already
#======================================
db_exists="no"
    psql -lqt | cut -d \| -f 1 | grep -qw $dbname
        if [ $? -eq 0 ]; then
            db_exists="yes"
        fi

#==================================================================
# End it if the input argument requires an existing database
#==================================================================
if [ $db_exists == "no" ]; then
     #==========================
     # Database does not exist
     #==========================
     LogMsg "[Info    ] $dbname database does not exist."
     echo "[Error   ] Cannot perform action because the $dbname database does not exist. Exiting."
     LogMsg "[Error   ] Cannot perform action because the $dbname database does not exist. Exiting."
     LogMsg "[End     ] Database does not exist"
     echo "${line1_out}"
     echo "${line3_log}" >> $logfile
     exit 0
fi

#----------------------------------------------------------------
# All the raw combined timing results before trimming
# Along with csm allocation history archive results
#----------------------------------------------------------------

csm_ras_type_count="csm_ras_type_count"

#-------------------------------------------------------------------------------
# psql csm_ras_type csv data import
#-------------------------------------------------------------------------------
return_code=0
ras_script_errors="$(mktemp)"
#trap 'rm -f "$ras_script_errors"' EXIT

if [ $loaddata == "yes" ]; then
    echo "[Info    ] $3 file exists"
    LogMsg "[Info    ] $3 file exists"
    echo "[Warning ] This will load and or update csm_ras_type table data into $dbname database. Do you want to continue [y/n]?"
    LogMsg "[Info    ] $dbname database insert/update process begin."
    read -s -n 1 loaddata
    case "$loaddata" in
        [yY][eE][sS]|[yY]) echo "[Info    ] User response: $loaddata"
        LogMsg "[Info    ] User response: $loaddata";;
        *)
            echo "[Info    ] User response: $loaddata"
            echo "[Info    ] Skipping the csm_ras_type table data import/update process"
            echo "${line2_log}"
            LogMsg "[Info    ] Skipping the csm_ras_type table data import/update process"
            LogMsg "[End     ] $dbname database Data load/update process has ended."
            echo "${line3_log}" >> $logfile
            return_code=1
            exit 0
        ;;
    esac

rtl_count=`psql -v ON_ERROR_STOP=1 -q -t -U $db_username -d $dbname -P format=wrapped << THE_END
select count(*) from csm_ras_type;
THE_END`

import_count=`psql -v ON_ERROR_STOP=1 -q -t -U $db_username -d $dbname -P format=wrapped << THE_END 2>>/dev/null
BEGIN;
LOCK TABLE csm_ras_type IN EXCLUSIVE MODE;
    DROP TABLE IF EXISTS tmp_ras_type_data;
    CREATE TEMP TABLE tmp_ras_type_data(msg_id text, severity ras_event_severity, message text, description text, control_action text, threshold_count int, threshold_period int, enabled boolean, set_state compute_node_states, visible_to_users boolean);
        \copy tmp_ras_type_data FROM '$csv_file_name' with csv header;
        WITH rows AS (
        UPDATE csm_ras_type
        SET
        severity = tmp_ras_type_data.severity,
        message = tmp_ras_type_data.message,
        description = tmp_ras_type_data.description,
        control_action = tmp_ras_type_data.control_action,
        threshold_count = tmp_ras_type_data.threshold_count,
        threshold_period = tmp_ras_type_data.threshold_period,
        enabled = tmp_ras_type_data.enabled,
        set_state = tmp_ras_type_data.set_state,
        visible_to_users = tmp_ras_type_data.visible_to_users
        FROM tmp_ras_type_data
        WHERE
        (csm_ras_type.severity <> tmp_ras_type_data.severity
        OR csm_ras_type.message <> tmp_ras_type_data.message
        OR csm_ras_type.description <> tmp_ras_type_data.description
        OR csm_ras_type.control_action <> tmp_ras_type_data.control_action
        OR csm_ras_type.threshold_count <> tmp_ras_type_data.threshold_count
        OR csm_ras_type.threshold_period <> tmp_ras_type_data.threshold_period
        OR csm_ras_type.enabled <> tmp_ras_type_data.enabled
        OR csm_ras_type.set_state <> tmp_ras_type_data.set_state
        OR csm_ras_type.visible_to_users <> tmp_ras_type_data.visible_to_users)
        AND csm_ras_type.msg_id = tmp_ras_type_data.msg_id
        RETURNING *)
        SELECT count(*) FROM rows;

        SELECT count(*) FROM tmp_ras_type_data;
        INSERT INTO csm_ras_type
        SELECT DISTINCT ON (msg_id) * FROM tmp_ras_type_data
            WHERE NOT EXISTS (
                SELECT msg_id
                FROM csm_ras_type crt
                WHERE
                tmp_ras_type_data.msg_id = crt.msg_id)
        ORDER BY msg_id ASC;
        select
        (SELECT "count"(*) as cnt1 from csm_ras_type) - (SELECT "count"(*) as cnt2 from tmp_ras_type_data) as total_count;
        select count(*) from csm_ras_type;
        select count(*) from csm_ras_type_audit;
COMMIT; 
THE_END`

if [[ $? -ne 0 ]]; then
     echo "[Error   ] Cannot perform action because the csv: $csv_file_name might not be compatible with the DB. Exiting."
     echo "[Info    ] Please check the file to ensure it is compatible with the csm_ras_type table."
     LogMsg "[Error   ] Cannot perform action because the csv: $csv_file_name might not be compatible with the DB. Exiting."
     LogMsg "[Info    ] Please check the file to ensure it is compatible with the csm_ras_type table."
     LogMsg "[End     ] Aborting csv process"
     echo "${line1_out}"
     echo "${line3_log}" >> $logfile
    exit 0
fi

count=$(grep -vc "^#" $csv_file_name)
set -- $import_count
#Difference=$(($count + $2))
diff=$(($count - $rtl_count))

    echo "[Info    ] csm_ras_type record count before script execution:$rtl_count"
    LogMsg "[Info    ] csm_ras_type record count before script execution:$rtl_count"
    echo "[Info    ] Record import count from $csv_file_name: $count"
    LogMsg "[Info    ] Record import count from $csv_file_name: $count"
    echo "[Info    ] Record update count from $csv_file_name: $1"
    LogMsg "[Info    ] Record update count from $csv_file_name: $1"
    echo "[Info    ] Total csm_ras_type insert count from file: $diff"
    LogMsg "[Info    ] Total csm_ras_type insert count from file: $diff"
    echo "[Info    ] csm_ras_type live row count after script execution: $4"
    LogMsg "[Info    ] csm_ras_type live row count after script execution: $4"
    echo "[Info    ] csm_ras_type_audit live row count: $5"
    LogMsg "[Info    ] csm_ras_type_audit live row count: $5"
    echo "[Info    ] Database: $dbname csv upload process complete for csm_ras_type table."
    LogMsg "[End     ] Database: $dbname csv upload process complete for csm_ras_type table."
    echo "${line2_log}"
    echo "${line3_log}" >> $logfile
    exit $return_code
fi

#===============================================
# Remove all data from the database tables
#===============================================
# return code added to ensure it was successful or failed during this step
#-------------------------------------------------------------------------
return_code=0
if [ $removedata == "yes" ]; then
    if [ ! -z "$3" ]; then
            if [ -f $csv_file_name ]; then
                echo "[Info    ] $3 file exists"
                LogMsg "[Info    ] $3 file exists"
            else    
                echo "[Error   ] File $csv_file_name can not be located or doesn't exist"
                echo "[Info    ] Please choose another file or check path"
                LogMsg "[Error   ] Cannot perform action because the $csv_file_name file does not exist. Exiting."
                echo "${line3_log}" >> $logfile
                echo "${line2_log}"
            exit 0
            fi
    fi
    echo "[Warning ] This will drop csm_ras_type table data from $dbname database. Do you want to continue [y/n]?"
    LogMsg "[Info    ] $dbname database drop process begin."
    read -s -n 1 removedata
    case "$removedata" in
        [yY][eE][sS]|[yY])
        echo "[Info    ] User response: $removedata"
        LogMsg "[Info    ] User response: $removedata"
delete_count_csm_ras_type=`psql -q -t -U $db_username $dbname << THE_END
            BEGIN;
            LOCK TABLE csm_ras_type IN EXCLUSIVE MODE;
            with delete_1 AS(
            DELETE FROM csm_ras_type RETURNING *)
            select count(*) from delete_1;
            select count(*) from csm_ras_type;
            select count(*) from csm_ras_type_audit;
            COMMIT;
THE_END`

set -- $delete_count_csm_ras_type
            
            echo "[Info    ] Record delete count from the csm_ras_type table: $1"
            LogMsg "[Info    ] Record delete count from the csm_ras_type table: $1"
            echo "[Info    ] csm_ras_type live row count: $2"
            LogMsg "[Info    ] csm_ras_type live row count: $2"
            echo "[Info    ] csm_ras_type_audit live row count: $3"
            LogMsg "[Info    ] csm_ras_type_audit live row count: $3"
            echo "[Info    ] Data from the csm_ras_type table has been successfully removed"
            LogMsg "[Info    ] Data from the csm_ras_type table has been successfully removed"
                if [ ! -z "$csv_file_name" ]; then
                    LogMsg "[Info    ] $dbname database remove all data from the csm_ras_type table."
                    echo "${line2_log}"
                else
                    LogMsg "[End     ] $dbname database remove all data from the csm_ras_type table."
                    echo "${line2_log}"
                    echo "${line3_log}" >> $logfile
                exit 0
                fi

rtl_count=`psql -q -t -U $db_username -d $dbname -P format=wrapped << THE_END
select count(*) from csm_ras_type;

THE_END`
import_count=`psql -v ON_ERROR_STOP=1 -q -t -U $db_username -d $dbname -P format=wrapped << THE_END 2>>/dev/null
BEGIN;
LOCK TABLE csm_ras_type IN EXCLUSIVE MODE;
    DROP TABLE IF EXISTS tmp_ras_type_data;
    CREATE TEMP TABLE tmp_ras_type_data(msg_id text, severity ras_event_severity, message text, description text, control_action text, threshold_count int, threshold_period int, enabled boolean, set_state compute_node_states, visible_to_users boolean);
        --as
        --SELECT * FROM csm_ras_type;
        \copy tmp_ras_type_data FROM '$csv_file_name' with csv header;
        UPDATE csm_ras_type
        SET
        severity = tmp_ras_type_data.severity,
        message = tmp_ras_type_data.message,
        description = tmp_ras_type_data.description,
        control_action = tmp_ras_type_data.control_action,
        threshold_count = tmp_ras_type_data.threshold_count,
        threshold_period = tmp_ras_type_data.threshold_period,
        enabled = tmp_ras_type_data.enabled,
        set_state = tmp_ras_type_data.set_state,
        visible_to_users = tmp_ras_type_data.visible_to_users
        FROM tmp_ras_type_data
        WHERE
        (csm_ras_type.severity <> tmp_ras_type_data.severity
        OR csm_ras_type.message <> tmp_ras_type_data.message
        OR csm_ras_type.description <> tmp_ras_type_data.description
        OR csm_ras_type.control_action <> tmp_ras_type_data.control_action
        OR csm_ras_type.threshold_count <> tmp_ras_type_data.threshold_count
        OR csm_ras_type.threshold_period <> tmp_ras_type_data.threshold_period
        OR csm_ras_type.enabled <> tmp_ras_type_data.enabled
        OR csm_ras_type.set_state <> tmp_ras_type_data.set_state
        OR csm_ras_type.visible_to_users <> tmp_ras_type_data.visible_to_users)
        AND csm_ras_type.msg_id = tmp_ras_type_data.msg_id;

        SELECT count(*) FROM tmp_ras_type_data;
        INSERT INTO csm_ras_type
        SELECT DISTINCT ON (msg_id) * FROM tmp_ras_type_data
            WHERE NOT EXISTS (
                SELECT msg_id
                FROM csm_ras_type crt
                WHERE
                tmp_ras_type_data.msg_id = crt.msg_id)
        ORDER BY msg_id ASC;
        select
        (SELECT "count"(*) as cnt1 from csm_ras_type) - (SELECT "count"(*) as cnt2 from tmp_ras_type_data) as total_count;
        select count(*) from csm_ras_type;
        select count(*) from csm_ras_type_audit;
COMMIT; 
THE_END` #2>>/dev/null

if [[ $? -ne 0 ]]; then
     echo "[Error   ] Cannot perform action because the csv: $csv_file_name might not be compatible with the DB. Exiting."
     echo "[Info    ] Please check the file to ensure it is compatible with the csm_ras_type table."
     LogMsg "[Error   ] Cannot perform action because the csv: $csv_file_name might not be compatible with the DB. Exiting."
     LogMsg "[Info    ] Please check the file to ensure it is compatible with the csm_ras_type table."
     LogMsg "[End     ] Aborting csv process"
     echo "${line1_out}"
     echo "${line3_log}" >> $logfile
    exit 0
fi

count=$(grep -vc "^#" $csv_file_name)
set -- $import_count
#Difference=$(($count + $2))
diff=$(($count - $rtl_count))

    echo "[Info    ] csm_ras_type record count before script execution:$rtl_count"
    LogMsg "[Info    ] csm_ras_type record count before script execution:$rtl_count"
    echo "[Info    ] Record import count from $csv_file_name: $count"
    LogMsg "[Info    ] Record import count from $csv_file_name: $count"
#   echo "[Info    ] Record update count from $csv_file_name: $1"
#   LogMsg "[Info    ] Record update count from $csv_file_name: $1"
    echo "[Info    ] Total csm_ras_type insert count from file: $diff"
    LogMsg "[Info    ] Total csm_ras_type insert count from file: $diff"
    echo "[Info    ] csm_ras_type live row count after script execution: $4"
    LogMsg "[Info    ] csm_ras_type live row count after script execution: $4"
    echo "[Info    ] csm_ras_type_audit live row count: $5"
    LogMsg "[Info    ] csm_ras_type_audit live row count: $5"
    echo "[Info    ] Database: $dbname csv upload process complete for csm_ras_type table."
    LogMsg "[End     ] Database: $dbname csv upload process complete for csm_ras_type table."
    echo "${line2_log}"
    echo "${line3_log}" >> $logfile
    exit $return_code
    echo "${line3_log}" >> $logfile
        ;;
        *)
            echo "[Info    ] User response: $removedata"
            LogMsg "[Info    ] User response: $removedata"
            echo "[Info    ] Data removal from the csm_ras_type table has been aborted"
            LogMsg "[Info    ] Data removal from the csm_ras_type table has been aborted"
            LogMsg "[End     ] $dbname database attempted removal process has ended."
            echo "${line2_log}"
            echo "${line3_log}" >> $logfile
            return_code=1
        ;;
    esac
exit $return_code
fi
