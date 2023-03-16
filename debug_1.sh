#! /bin/bash

function search() {

    # gets: string with a record name or part of name
    # use 'grep' to search the file and return values accordingly
    # if there is more then one result for the search
    # return a sorted (use sort() function) list of all matching records and the amount
    # if no matches return Failure else Success
    # write to log file

    local keyphrase=$1
    local search_results="search_results.csv"
    $(grep -i $keyphrase $db_file | sort | nl > $search_results)
    echo $search_results
}

function print_search() {
    local keyphrase=$1
    local search_file=$(search $keyphrase)
    if [ -s $search_file ];
    then    
        cat $search_file
        # write_to_log "Search" "Success"        
    else
        echo "No matching records were found"
        # write_to_log "Search" "Failure"       
    fi
}    

function choose_record_update() {
    local num_lines=$1
    local action=$2
    local user_choice        # Define a local variable to hold user choice
    local flag=0
    while [ $flag -eq 0 ]
    do
        echo "Please enter the number of record you would like to $2: "
        if [ $action == "delete" ];
        then
            echo "0: Cancel - Abort Operation"
        elif [ $action == "insert" ];
        then    
            echo "0: Append record to DB file"
        fi

        read user_choice
        if [[ $user_choice =~ ^[1-9]{1}[0-9]*$ && $user_choice -le $num_lines ]]; 
        then   # Check whether user choice is valid
            flag=1
        else    
            echo "Error: invalid choice, please try again!"
        fi
    done
    return $user_choice
}

db_file="recordsDB.csv"
# print_search on
choose_record_update 5 "insert"
choice=$?
echo $choice