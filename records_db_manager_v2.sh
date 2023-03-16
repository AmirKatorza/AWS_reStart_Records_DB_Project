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
    $(grep -i $keyphrase $db_file | sort > $search_results)
    echo $search_results
}

function print_search() {
    local keyphrase=$1
    local search_file=$(search $keyphrase)
    if [ -s $search_file ];
    then    
        cat $search_file | nl
        write_to_log "Search" "Success"        
    else
        echo "No matching records were found"
        write_to_log "Search" "Failure"       
    fi
}    

function choose_record_update() {
    local search_file=$1
    local num_lines=$2
    echo $num_lines
    local action=$3
    local user_choice        # Define a local variable to hold user choice
    local flag=0
    while [ $flag -eq 0 ]
    do
        cat $search_file | nl
        echo "Please enter the number of record you wish to $3: "
        if [[ $action == "delete" ]];
        then
            echo "0: Cancel - Abort Operation"
        elif [[ $action == "update" ]];
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

function add_record() {
    
    # gets: record_name , amount (consider getting an array arr[0]= name, arr[1]=amount)
    # relies on search() function
    # probably we will need to implement search function first
    # call search() function
    # if record exists then add to amount
    # consider using 'sed' utility to replace valuse inside the csv file
    # else (seach function returned empty)append record to csv file
    # echo "Success"
    # write to log file    
    
    local record_name=$1    # Holds record's name (or part of it) to be deleted! 
    local amount=$2         # Holds the amount of records to be deleted
    local search_results_file=$(search $record_name)    # Holds the name of the search results file
    if [ -s $search_results_file ]; # Check whether the file is empty
    then                
        # The file is not-empty.        
        local num_lines=$(wc -l < $search_results_file)    # Holds the number of lines in search result file
        choose_record_update $search_results_file $num_lines "update"
        local choice=$?
                
        if [ $choice -gt 0 ];       
        then    # Update existing record
            local record_chosen=$(sed -n ${choice}p $search_results_file)  # Holds the entire row chosen
            local record_array       # Parse entire raw to array 
            IFS="," read -a record_array <<< $record_chosen
            local current_amount=${record_array[1]}                # Extract current amount of records
            local updated_amount=$(( $current_amount + $amount ))   # Update records amount after addition 
            local updated_record="${record_array[0]},${updated_amount}" # Concat record name to updated amount
            $(sed -i "s/${record_chosen}/${updated_record}/g" $db_file)    # Update the DB file
            write_to_log "Insert" "Success"
            echo "Record was updated successfully"      # Print Success
        else    # Append new record to DB file
            local updated_record="${record_name},${amount}"
            echo "$updated_record" >> $db_file
            write_to_log "Insert" "Success"
            echo "New record was added successfully!"  
        fi
    else
        local updated_record="${record_name},${amount}"
        echo "$updated_record" >> $db_file
        write_to_log "Insert" "Success"
        echo "New record was added successfully!"
    fi
}

function delete() {
    
    # depends on search()
    # gets: record_name , amount (consider getting an array arr[0]= name, arr[1]=amount) 
    # use search() function
    # if search returned more than one result we will need to prompt a new menu
    # and ask which record to delete
    # otherwise update the amount of records in the csv file
    # if after amount update the amount is 0, delete the record from the file
    # if we try to delete more than the amount we will need to prompt an error message
    # echo Success/Failure
    # write to log file
    
    local record_name=$1    # Holds record's name (or part of it) to be deleted! 
    local amount=$2         # Holds the amount of records to be deleted
    local search_results_file=$(search $record_name)    # Holds the name of the search results file
    # echo $search_results_file
    if [ -s $search_results_file ]; then                # Check whether the file is empty
        # The file is not-empty.
        local num_lines=$(wc -l < $search_results_file)    # Holds the number of lines in search result file
        choose_record_update $search_results_file $num_lines "delete"
        local choice=$?
               
        if [ $choice -eq 0 ];       # User chose to cancel his action print "Failure"
        then
            write_to_log "Delete" "Failure"
            echo "Failure: You chose to abort!"
        else
            local record_chosen=$(sed -n ${choice}p $search_results_file)  # Holds the entire row chosen
            local record_array    
            IFS="," read -a record_array <<< $record_chosen           # Parse raw to array
            local current_amount=${record_array[1]}                # Extract current amount of records
            if [ $current_amount -lt $amount ];     # If amount given was greater then current amount print "Failure"
            then      
                write_to_log "Delete" "Failure"
                echo "Failure: Amount is higher than inventory"
            else
                local updated_amount=$(( $current_amount - $amount ))   # Update records amount after deletion 
                if [ $updated_amount -eq 0 ]; 
                then
                    $(sed -i "/$record_chosen/d" $db_file)         # If amount is 0 delete the record from DB
                else
                    local updated_record="${rec_array[0]},${updated_amount}" # Concat record name to updated amount
                    $(sed -i "s/${record_chosen}/${updated_record}/g" $db_file)    # Update the DB file
                fi
                write_to_log "Delete" "Success"
                echo "Record was deleted successfully!"      # Print Success
            fi
        fi        
    else
        write_to_log "Delete" "Failure"
        echo "Failure: search result returned empty"    # Print Failure due to empty search file
    fi
}

function update_name() {
    
    # depends on search() function
    # gets: old name, new name
    # if more then one match than prompt a menu with matches number
    # if no match echo Failure
    # else update the record use 'sed' utility
    # echo Success/Failure
    # write to log file
    
    local old_name=$1
    local new_name=$2
    local search_results_file=$(search $old_name)    
    if [ -s $search_results_file ]; 
    then              
        local num_lines=$(wc -l < $search_results_file)
        choose_record_update $search_results_file $num_lines "delete"
        local choice=$?
        if [ $choise -ne 0 ];
        then
            local record_chosen=$(sed -n ${choice}p $search_results_file)
            local current_name=$(echo $record_chosen | cut -d "," f 1) 
            $(sed -i 's/$current_name/$new_name/g' $db_file)
            write_to_log "UpdateName" "Success"
            echo "Success: Record was updated Succefuly!"            
        else
            write_to_log "UpdateAmount" "Failure"
            echo "Failure: You chose to abort"            
        fi
    else
        write_to_log "UpdateAmount" "Failure"
        echo "Failure: Record was not found!"
    fi
}

function update_amount() {
    
    # depends name of record, amount
    # if amount < 0 echo "error message"
    # gets: old name, new name
    # if more then one match than prompt a menu with matches number
    # if no match echo Failure
    # else update te record use 'sed' utility
    # echo Success/Failure
    # write to log file

    local record_name=$1
    local new_amount=$2
    local search_results_file=$(search $old_name)    
    if [ -s $search_results_file ]; 
    then              
        local num_lines=$(wc -l < $search_results_file)
        choose_record_update $search_results_file $num_lines "delete"
        local choice=$?
        if [ $choice -ne 0 ];
        then
            local record_chosen=$(sed -n ${choice}p $search_results_file)
            local updaed_record=$(echo $record_chosen | awk -F "," '$2=${new_amount}')
            $(sed -i 's/$record_chosen/$updated_record/g' $db_file) 
            write_to_log "UpdateAmount" "Success"
            echo "Success: Record was updated Succefuly!"
        else
            write_to_log "UpdateAmount" "Failure"
            echo "Failure: You chose to abort"
        fi
    else
        write_to_log "UpdateAmount" "Failure"
        echo "Failure: Record was not found!"        
    fi    
}

function print_amount() {
    
    # gets: void
    # loop over all the records and sum the amount values
    # if sum > 0 echo sum
    # else prompt "File is empty"
    # write to log file
    
    local total=$(awk -F "," '{Total=Total+$2} END{print Total}' $db_file)
    if [ $total -gt 0 ];
    then    
        write_to_log "PrintAmount" "$total"
        echo "The total number of record in Data Base is: $total"
    else
        write_to_log "PrintAmount" "Failure"
        echo "There are no records in the Data Base at the current time"
    fi
}

function print_all_sorted() {
    
    # gets: void
    # sort all the records and print the records sorted with amount
    # else prompt "File is empty"
    # write to log file

    if [[ -s $db_file ]] 
    then    
        $(sort $db_file > sorted_df.csv)
        echo "Printing all records in Data Base: "
        while read ln
        do
            echo "$ln"
            local record_name=$(echo $ln | awk -F "," '{print $1}')
            local record_count=$(echo $ln | awk -F "," '{print $2}')
            local tmp_record="$record_name $record_count"
            write_to_log "PrintAll" "$tmp_record"               
        done < sorted_df.csv
    else
        write_to_log "PrintAll" "Failure"
        echo "No records found. Data Base is empty!"                
    fi
}

function write_to_log() {
    local option=$1
    local indication=$2
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")    
    echo "$timestamp $option $indication" >> recordsDB_log.txt    
}

function main() {
    select opt in Insert Delete Search Update_Name Update_Amount Print_Amount Print_All Exit
    do
        case $opt in 
            Insert )
                read -p "Please enter the record name or part of it: " name1
                read -p "Please enter the record amount that you wish to add: " amount1
                if [[ $name1 =~ ^[a-zA-Z0-9\s]+$ && $amount1 =~ ^[1-9]{1}[0-9]*$ ]]
                then
                    add_record $name1 $amount1
                else
                    write_to_log "Insert" "Failure"
                    echo "Input is invalid"
                fi
            ;;
            Delete )                
                read -p "Please enter the record name or part of it: " name 
                read -p "Please enter the record amount that you wish to add " amount
                if [[ $name =~ ^[A-Za-z0-9\s]+$ && $amount =~ ^[1-9]{1}[0-9]*$ ]];
                then
                    delete $name $amount
                else
                    write_to_log "Delete" "Failure"
                    echo "Input is invalid"
                fi
            ;; 
            Search )
                read -p "Please enter the record name or part of it: " name 
                if [[ $name =~ ^[A-Za-z0-9\s]+$ ]];
                then
                    print_search $name
                else
                    write_to_log "Search" "Failure"
                    echo "Input is invalid"
                fi
            ;; 
            Update_Name )
                read -p "Please enter the record name or part of it: " old_name 
                read -p "Please enter the new name you wish to replace: " new_name
                if [[ $old_name =~ ^[A-Za-z0-9\s]+$ && $new_name =~ ^[A-Za-z0-9\s]+$ ]];
                then
                    update_name $old_name $new_name
                else
                    write_to_log "UpdateName" "Failure"
                    echo "Input is invalid"
                fi
            ;; 
            Update_Amount )
                read -p "Please enter the record name or part of it: " name 
                read -p "Please enter the record amount that you wish to add " amount
                if [[ $name =~ ^[A-Za-z0-9\s]+$ && $amount =~ ^[1-9]{1}[0-9]*$ ]];
                then
                    update_amount $name $amount
                else
                    write_to_log "UpdateAmount" "Failure"
                    echo "Input is invalid"
                fi
            ;; 
            Print_Amount )
                print_amount
            ;; 
            Print_All )
                print_all_sorted
            ;;
            Exit )
                exit
            ;;
        esac
    done
}

db_file="recordsDB.csv"
main