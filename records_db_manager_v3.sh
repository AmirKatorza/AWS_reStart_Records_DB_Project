#! /bin/bash

function create_search_file() {

    # get: string with a record name or part of name
    # use 'grep' to search the file and return values accordingly
    # if there is more then one result for the search
    # return a sorted list of all matching records and the amounts
    # if no matches return an empty file
    
    local keyphrase=$1
    local search_results="search_results.csv"
    $(grep -i $keyphrase $db_file | sort > $search_results)
    echo $search_results
}

function Search() {
    local keyphrase=$1
    local search_file=$(create_search_file $keyphrase)
    if [ -s $search_file ]
    then    
        cat $search_file | nl
        write_to_log ${FUNCNAME[0]} 1 # 1 means success        
    else
        echo "Failure: No matching records were found"
        write_to_log ${FUNCNAME[0]} 0 # 0 mean Failure       
    fi
}  

function choose_record_update() {
    local search_file=$1
    local other=$2
    local user_choice        # Define a local variable to hold user choice
    local num_lines=$(wc -l < $search_file) 
    if [ num_lines -eq 1 ]
    then
        user_choice=1
        return $user_choice
    else
        if [ $other == "insert" ]
        then
            $(sed -i '1i Add record to Data Base' $search_file)
        else
            $(sed -i '1i Cancel Operation' $search_file)
        fi
        local flag=0
        while [ $flag -eq 0 ]
        do
            echo "Please enter the number of record you wish to update: "
            cat $search_file | nl -v 0            
            read user_choice
            if [[ $user_choice =~ ^[0-9]+$ && $user_choice -le $num_lines ]] # Check whether user choice is valid
            then   
                flag=1
            else    
                echo "Error: invalid choice, please try again!"
            fi
        done
        return $user_choice
}

function UpdateName() {
    
    # get: old name, new name
    # relies on Search() function
    # if more then one match than prompt a menu with matches number
    # if no match print Failure, else update the record, use 'sed' utility
    # echo Success/Failure
    # write to log file
    
    local old_name=$1
    local new_name=$2
    local search_results_file=$(search $old_name)    
    if [ -s $search_results_file ] 
    then              
        choose_record_update $search_results_file "other"
        local choice=$?
        if [ $choise -ne 0 ]
        then
            local record_chosen=$(sed -n ${choice}p $search_results_file)
            local current_name=$(echo $record_chosen | cut -d "," f 1) 
            $(sed -i 's/$current_name/$new_name/g' $db_file)
            write_to_log ${FUNCNAME[0]} 1
            echo "Success: Record was updated Succefuly!"
        else
            write_to_log ${FUNCNAME[0]} 0
            echo "Failure: User chose to Abort!"
        fi
    else
        write_to_log ${FUNCNAME[0]} 0
        echo "Failure: Record was not found!"
    fi
}

function UpdateAmount() {
    
    # depends name of record, amount
    # if amount < 0 echo "error message"
    # get: old name, new name
    # if more then one match than prompt a menu with matches number
    # if no match echo Failure
    # else update te record use 'sed' utility
    # echo Success/Failure
    # write to log file

    local record_name=$1
    local new_amount=$2
    local search_results_file=$(search $record_name)    
    if [ -s $search_results_file ]; 
    then              
        choose_record_update $search_results_file "other"
        local choice=$?
        if [ $choise -ne 0 ]
        then
            local record_chosen=$(sed -n ${choice}p $search_results_file)
            local updaed_record=$(echo $record_chosen | awk -F "," '$2=${new_amount}')
            $(sed -i 's/$record_chosen/$updated_record/g' $db_file) 
            write_to_log ${FUNCNAME[0]} 1
            echo "Success: Record was updated Succefuly!"
        else
            write_to_log ${FUNCNAME[0]} 0
            echo "Failure: User chose to Abort!"
        fi
    else
        write_to_log ${FUNCNAME[0]} 0
        echo "Failure: Record was not found!"        
    fi    
}

function Insert() {
    
    # get: record_name , amount 
    # call search() function
    # if record exists then add to amount
    # else (search function returned empty) append record to csv file
    # write to log file    
    
    local record_name=$1    # Holds record's name (or part of it) to be deleted! 
    local amount=$2         # Holds the amount of records to be deleted
    local search_results_file=$(search $record_name)    # Holds the name of the search results file
    if [ -s $search_results_file ]; # Check whether the file is empty
    then                
        # The file is not-empty.        
        choose_record_update $search_results_file "other"
        local choice=$?
                
        if [ $choice -ne 0 ];       
        then    # Update existing record
            local record_chosen=$(sed -n ${choice}p $search_results_file)  # Holds the entire row chosen
            local record_array       # Parse entire raw to array 
            IFS="," read -a record_array <<< $record_chosen
            local current_amount=${record_array[1]}                # Extract current amount of records
            local updated_amount=$(( $current_amount + $amount ))   # Update records amount after addition 
            local updated_record="${record_array[0]},${updated_amount}" # Concat record name to updated amount
            $(sed -i "s/${record_chosen}/${updated_record}/g" $db_file)    # Update the DB file
            write_to_log ${FUNCNAME[0]} 1
            echo "Success: Record was updated successfully"      # Print Success
        else    # Append new record to DB file
            local updated_record="${record_name},${amount}"
            echo "$updated_record" >> $db_file
            write_to_log ${FUNCNAME[0]} 1
            echo "Success: New record was added successfully!"  
        fi
    else
        local updated_record="${record_name},${amount}"
        echo "$updated_record" >> $db_file
        write_to_log ${FUNCNAME[0]} 1
        echo "Success: New record was added successfully!"
    fi
}

function Delete() {
    
    # get: record_name , amount
    # if search returned more than one result we will need to prompt a new menu
    # and ask which record to delete
    # otherwise update the amount of records in the csv file
    # if after amount update the amount is 0, delete the record from the file
    # if we try to delete more than the current amount we will need to prompt an error message
    # write to log file
    
    local record_name=$1    # Holds record's name (or part of it) to be deleted! 
    local amount=$2         # Holds the amount of records to be deleted
    local search_results_file=$(search $record_name)    # Holds the name of the search results file
   
    if [ -s $search_results_file ] # Check whether the file is empty
    then    # The file is not-empty.          
        choose_record_update $search_results_file "other"
        local choice=$?               
        if [ $choice -ne 0 ];       # User chose to cancel his action print "Failure"
        then
            local record_chosen=$(sed -n ${choice}p $search_results_file)  # Holds the entire row chosen
            local record_array    
            IFS="," read -a record_array <<< $record_chosen           # Parse raw to array
            local current_amount=${record_array[1]}                # Extract current amount of records
            if [ $current_amount -lt $amount ];     # If amount given was greater then current amount print "Failure"
            then      
                write_to_log ${FUNCNAME[0]} 0
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
                write_to_log ${FUNCNAME[0]} 1
                echo "Success: Record was deleted successfully!"      # Print Success
            fi
        else
            write_to_log ${FUNCNAME[0]} 0
            echo "Failure: User chose to Abort!"
        
        fi        
    else
        write_to_log "Delete" "Failure"
        echo "Failure: search result returned empty"    # Print Failure due to empty search file
    fi
}

function PrintAmount() {
    
    # get: void
    # loop over all the records and sum the amount values
    # if sum > 0 echo sum
    # else prompt "File is empty"
    # write to log file
    
    local total=$(awk -F "," '{Total=Total+$2} END{print Total}' $db_file)
    if [ $total -gt 0 ];
    then    
        write_to_log ${FUNCNAME[0]} "$total"
        echo "The total number of record in Data Base is: $total"
    else
        write_to_log ${FUNCNAME[0]} 0
        echo "There are no records in the Data Base at the current time"
    fi
}

function PrintAll() {
    
    # get: void
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
            write_to_log ${FUNCNAME[0]} "$tmp_record"               
        done < sorted_df.csv
    else
        write_to_log ${FUNCNAME[0]} 0
        echo "No records found. Data Base is empty!"                
    fi
}

function write_to_log() {
    local action=$1
    local indication=$2
    if [ $indication -eq 1 ]
    then
        indication="Success"
    else
        indication="Failure"
    fi
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")        
    echo "$timestamp $option $indication" >> recordsDB_log.txt    
}

function main() {
    local flag=1
    while [ $flag -eq 1 ]
    do
        clear
        echo "-------------Records Data Base-------------"
        echo "1 - Add a new record to DB or update update quantity."
        echo "2 - Delete a record from DB or update quantity."
        echo "3 - Search a record in DB."
        echo "4 - Update a name of a record."
        echo "5 - Update quantity of a record."
        echo "6 - Print the Sum of all records in the DB."
        echo "7 - Print the entire DB sorted bt name."
        echo "8 - Exit!"
        read -p "Please choose you action :" opt

        case $opt in 
            1 )
                read -p "Please enter the record name or part of it: " name1
                read -p "Please enter the record amount that you wish to add: " amount1
                if [[ $name1 =~ ^[a-zA-Z0-9\s]+$ && $amount1 =~ ^[1-9]{1}[0-9]*$ ]]
                then
                    Insert $name1 $amount1
                else
                    echo "Input is invalid"
                fi
                read -p "Press Enter to Continue" 
            ;;
            2 )                
                read -p "Please enter the record name or part of it: " name 
                read -p "Please enter the record amount that you wish to add " amount
                if [[ $name =~ ^[A-Za-z0-9\s]+$ && $amount =~ ^[1-9]{1}[0-9]*$ ]];
                then
                    Delete $name $amount
                else
                    echo "Input is invalid"
                fi
                read -p "Press Enter to Continue" 
            ;; 
            3 )
                read -p "Please enter the record name or part of it: " name 
                if [[ $name =~ ^[A-Za-z0-9\s]+$ ]];
                then
                    Search $name
                else
                    echo "Input is invalid"
                fi
                read -p "Press Enter to Continue" 
            ;; 
            4 )
                read -p "Please enter the record name or part of it: " old_name 
                read -p "Please enter the new name you wish to replace: " new_name
                if [[ $old_name =~ ^[A-Za-z0-9\s]+$ && $new_name =~ ^[A-Za-z0-9\s]+$ ]];
                then
                    update_name $old_name $new_name
                else
                    echo "Input is invalid"
                fi
                read -p "Press Enter to Continue" 
            ;; 
            5 )
                read -p "Please enter the record name or part of it: " name 
                read -p "Please enter the record amount that you wish to add " amount
                if [[ $name =~ ^[A-Za-z0-9\s]+$ && $amount =~ ^[1-9]{1}[0-9]*$ ]];
                then
                    update_amount $name $amount
                else
                    echo "Input is invalid"
                fi
                read -p "Press Enter to Continue" 
            ;; 
            6 )
                print_amount
                read -p "Press Enter to Continue" 
            ;; 
            7 )
                print_all_sorted
                read -p "Press Enter to Continue" 
            ;;
            8 )
                exit
            ;;
            * )
                echo "Please enter a valid number between 1-8"
                read -p "Press Enter to Continue" 
            ;;
        esac
    done    
}

db_file="recordsDB.csv"
main