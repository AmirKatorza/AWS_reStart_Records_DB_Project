#! /bin/bash

function search() {
    # Rahamim
    # depends on sort()
    # gets: string with a record name or part of name
    # use use 'grep' to search the file and return values accordingly
    # if there is more then one result for the search
    # return a sorted (use sort() function) list of all matching records and the amount
    # if no matches return Failure else Success
    # write to log file
    local keyphrase=$1
    local search_results="search_results.sh"
    $(grep -i $keyphrase $db_file | sort | nl > $search_results)
    print_search_file $search_results
    echo $search_results
}

function print_search_file() {
    local file_name=$1
    while read ln
    do
        echo $ln
    done < $file_name
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
    echo $search_results_file
    if [ -s $search_results_file ]; then                # Check whether the file is empty
        # The file is not-empty.
        local num_lines_search=$(wc -l < $search_results_file)    # Holds the number of lines in search result file
        echo $num_lines_search
        print_search_file $search_results_file          # Call print_search_file function to print the contant of search result file
        local choice        # Define a local variable to hold user choice
        local flag=0
        while [ $flag -eq 0 ]
        do
            echo "Please enter the number of record you would like to delete: "
            read choice
            if [[ $choice -ge 0 && $choice -le $num_lines_search ]]; 
            then   # Check whether user choice is valid
                flag=1
            fi
        done
        if [ $choice -eq 0 ];       # or user chose to cancel his action print "Failure"
        then
            echo "Failure"
        else
            local rec_chosen=`head -n $choice $search_results_file | tail -1`  # Holds the entire row chosen
            echo $rec_chosen
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

function print_amount() {
    # Mohammad
    # gets: void
    # loop over all the records and sum the amount values
    # if sum > 0 echo sum
    # else prompt "File is empty"
    # write to log file
    local total=$(awk -F "," '{Total=Total+$2} END{print Total}' $db_file)
    echo $total
    if [ $total -gt 0 ];
    then    
        echo "The total number of record is: $total"
    else
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
        while read ln
        do
            echo "$ln"
        done < sorted_df.csv
    else
        echo "Data Base is empty!"        
    fi
}

function print_randa() {
    if [ ! -f $db_file ]; 
    then
        echo "No records found."
    else
        # Sort records file by album name and count occurrences
        sort $db_file > sorted_records.txt   
  
        # Print sorted records
        echo -e "Album Name\tCount"
        while read line; 
        do
            local name=$(echo $line | awk -F "," '{print $1}')
            local count=$(echo $line | awk -F "," '{print $2}')            
            echo -e "$name\t$count"
        done < sorted_records.txt

        # Log result and return to main menu
        echo "Sorted records printed."
        echo "$(date): Printed sorted records" >> log.txt
    fi
}

db_file="recordsDB.csv"
# print_amount 
# print_all_sorted
# print_randa
search_results_file=$(search b)