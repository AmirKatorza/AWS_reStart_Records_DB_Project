#! /bin/bash

function search() {
    # relies on sort() function
    # gets: string with a record name or part of name
    # use use 'grep' to search the file and return values accordingly
    # if there is more then one result for the search
    # return a sorted (use sort() function) list of all matching records and the amount
    # if no matches return Failure else Success
    # write to log file
    local keyphrase=$1
    local search_results="search_results.sh"
    $(grep -i $keyphrase $db_file | sort > $search_results)
    if [ -s $search_results_file ];
    then    
        print_search_file $search_results
        local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
        echo "$timestamp Search Success" >> recordsDB_log.txt
        echo $search_results
    else
        local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
        echo "$timestamp Search Failure" >> recordsDB_log.txt
        echo "No matching records were found"
        echo ""
    fi
}

function print_search_file() {
    local file_name=$1
    index=1
    while read ln
    do
        echo "$index: $ln"
        (( index++ ))
    done < $file_name
    echo "0: Other"
}

function choose_record_update() {
    local num_lines=$1
    local action=$2
    local user_choice        # Define a local variable to hold user choice
    local flag=0
    while [ $flag -eq 0 ]
    do
        echo "Please enter the number of record you would like to update: "
        if [ $action == "delete" ];
        then
            echo "0: Other = Cancel"
        elif [ $action == "insert" ];
        then    
            echo "0: Other = Append record to DB file"
        fi

        read user_choice
        if [[ $user_choice =~ '^[0-9]+$' && $user_choice -ge 0 && $user_choice -le $num_lines ]]; 
        then   # Check whether user choice is valid
            flag=1
        else    
            echo "The input is invalid, please try again!"
        fi
    done
    echo "$user_choise"
}

function insert() {
    # Denise
    # depends on search
    # gets: record_name , amount (consider getting an array arr[0]= name, arr[1]=amount)
    # probably we will need to implement search function first
    # call search() function
    # if record exists than add to amount
    # consider using 'sed' utility to replace valuse inside the csv file
    # else (seach function returned empty)append record to csv file
    # echo "Success"
    # write to log file    
    
    local record_name=$1    # Holds record's name (or part of it) to be deleted! 
    local amount=$2         # Holds the amount of records to be deleted
    local search_results_file=$(search $record_name)    # Holds the name of the search results file
    # echo $search_results_file
    if [ $search_results_file != "" ]; then                # Check whether the file is empty
        # The file is not-empty.
        local num_lines_search=$(wc -l < $search_results_file)    # Holds the number of lines in search result file
        local choice=$(choose_record_update $num_lines_search "insert")
        
        if [ $choice -ne 0 ]; # Update existing record      
        then
            local rec_chosen=`head -n $choice $search_results_file | tail -1`  # Holds the entire row chosen
            echo $rec_chosen
            local rec_array                     # Parse raw to array 
            IFS="," read -a rec_array <<< $rec_chosen
            local current_amount=${rec_array[1]}                # Extract current amount of records
            local updated_amount=$(( $current_amount + $amount ))   # Update records amount after addition 
            local updated_record="${rec_array[0]},${updated_amount}" # Concat record name to updated amount
            $(sed -i "s/$rec_chosen/$updated_record/g" $db_file)    # Update the DB file
            echo "Success"      # Print Success
        else    # Append new record to DB file
            local updated_record="${record_name},${amount}"
            $(sed -i "s/$rec_chosen/$updated_record/g" $db_file)
            echo "echo Success"    # Print Failure due to empty search file        
        fi
    else
        local updated_record="${record_name},${amount}"
        $(sed -i "s/$rec_chosen/$updated_record/g" $db_file)
        echo "echo Success"    # Print Failure due to empty search file
    fi
}

function delete() {
    # Amir
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
        local num_lines_search=$(wc -l < $search_results_file)    # Holds the number of lines in search result file
        # echo $num_lines_search
        print_search_file $search_results_file          # Call print_search_file function to print the contant of search result file
        
        local choice=$(choose_record_update $num_lines_search "delete")
        
        if [ $choice -eq 0 ];       # User chose to cancel his action print "Failure"
        then
            echo "Failure"
        else
            local rec_chosen=`head -n $choice $search_results_file | tail -1`  # Holds the entire row chosen
            # echo $rec_chosen
            local rec_array # =(`echo $rec_chosen | tr ',' ' '`)   # Parse raw to array 
            IFS="," read -a rec_array <<< $rec_chosen
            local current_amount=${rec_array[1]}                # Extract current amount of records
            if [ $current_amount -lt $amount ];     # If amount given was greater then current amount print "Failure"
            then      
                echo "Failure"
            else
                local updated_amount=$(( $current_amount - $amount ))   # Update records amount after deletion 
                if [ $updated_amount -eq 0 ]; then
                    $(sed -i "/$rec_chosen/d" $db_file)         # If amount is 0 delete the record from DB
                else
                    local updated_record="${rec_array[0]},${updated_amount}" # Concat record name to updated amount
                    $(sed -i "s/$rec_chosen/$updated_record/g" $db_file)    # Update the DB file
                fi
                echo "Success"      # Print Success
            fi
        fi        
    else
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

}

function update_amount() {
    # Randa
    # depends name of record, amount
    # if amount < 0 echo "error message"
    # gets: old name, new name
    # if more then one match than prompt a menu with matches number
    # if no match echo Failure
    # else update te record use 'sed' utility
    # echo Success/Failure
    # write to log file
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
        local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
        echo "$timestamp PrintAmount $total" >> recordsDB_log.txt
        echo "The total number of record in Data Base is: $total"
    else
        local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
        echo "$timestamp PrintAmount Failure" >> recordsDB_log.txt
        echo "There are no records in the Data Base at the current time"
    fi
}

function print_all_sorted() {
    # Randa
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
            local record_name=$(echo $line | awk -F "," '{print $1}')
            local record_count=$(echo $line | awk -F "," '{print $2}')
            local timestamp=$(date +"%Y-%m-%d %H:%M:%S")            
            echo "$timestamp PrintAll $name $count" >> recordsDB_log.txt 
        done < sorted_df.csv
    else
        echo "No records found. Data Base is empty!" 
        local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
        echo "$timestamp PrintAll Failure" >> recordsDB_log.txt        
    fi
}

function write_to_log() {

}

db_file="recordsDB.csv"

function main() {
    select opt in Insert Delete Search Update_Name Update_Amount Print_Amount Print_All Exit
    do
        case $opt in 
            Insert )
            ;;
            Delete )                
            ;; 
            Search )
            ;; 
            Update_Name )
            ;; 
            Update_Amount )
            ;; 
            Print_Amount )
            ;; 
            Print_All )
            ;;
            Exit )
                exit
            ;;
        esac
    done
}

