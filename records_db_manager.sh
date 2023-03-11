#! /bin/bash

function insert() {
    # Denise
    # depends on search
    # gets: record_name , amount (consider getting an array arr[0]= name, arr[1]=amount)
    # probably we will need to implement serch function first
    # call search() function
    # if record exists than add to amount
    # consider using 'sed' utility to replace valuse inside the csv file
    # else (seach function returned empty)append record to csv file
    # echo "Success"
    # write to log file    
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
}

function search() {
    # Rahamim
    # depends on sort()
    # gets: string with a record name or part of name
    # use use 'grep' to search the file and return values accordingly
    # if there is more then one result for the search
    # return a sorted (use sort() function) list of all matching records and the amount
    # if no matches return Failure else Success
    # write to log file
}

function update_name() {
    # depends on search() function
    # gets: old name, new name
    # if more then one match than prompt a menu with matches number
    # if no match echo Failure
    # else update te record use 'sed' utility
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
    # Mohammad
    # gets: void
    # loop over all the records and sum the amount values
    # if sum > 0 echo sum
    # else prompt "File is empty"
    # write to log file
}

function print_all_sorted() {
    # Randa
    # gets: void
    # sort all the records and print the records sorted with amount
    # if sum > 0 echo sum
    # else prompt "File is empty"
    # write to log file
}

function write_to_log() {

}

# db_file_path=$1

if [[ -s $filname ]] 
then    
    echo error
else
    $(cat $filename | sort)

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

