#!/bin/sh

# set up directories for root directory, todo items, completed items.

# version control
declare -r version="1.0"
# root directory
declare -r ROOT_DIR=~/.todo
# directory for storing todo items
declare -r TODO_DIR=$ROOT_DIR/TODO
# directory for storing completed items
declare -r TODOC_DIR=$ROOT_DIR/TODO.COMPLETED

# Help menu

show_help() {
    echo "help menu:"
    echo "add (item): add a new item to the to-do list"
    echo "list: lists all to-do items"
    echo "list completed: lists all completed items"
    echo "complete (number): mark the item as complete"
    echo "help: The information listed here"
}



# Create directories if they do not exist

init() {
	if [ ! -d $ROOT_DIR ];then
		mkdir $ROOT_DIR
	fi
    chmod 700 $ROOT_DIR

	if [ ! -d $TODO_DIR ];then
		mkdir $TODO_DIR
	fi 
    chmod 700 $TODO_DIR
    
	if [ ! -d $TODOC_DIR ];then
		mkdir $TODOC_DIR
	fi
    chmod 700 $TODOC_DIR
    
}


# Display the details of a todo item

todo_list_detail() {
    if [ -z $@ ]; then
        echo "No item number provided for detailed listing"
    else
        filename=$TODO_DIR/$@
        if [ ! -f $filename ]; then
            echo "Item does not exist"
        else
            cat $filename
        fi
    fi
}


# List all to do items


todo_list_all() {

    count=0
    echo " List of all to-do items"
    for file in $TODO_DIR/*; do
        if [ -f $file ]; then
            title=$(head -n 1 $file)
            count=$(($count+1))
            echo "$count: $title"
        fi
    done
    if [ $count -eq 0 ]; then
        echo "The to do list is empty"
    fi
}


# List all completed to-do items

todo_list_comp() {
    count=0
    echo " List of all completed tasks"
    for file in $TODOC_DIR/*; do
        if [ -f $file ]; then
            title=$(head -n 1 $file)
            count=$(($count+1))
            echo "$count: $title"
        fi
    done
    if [ $count -eq 0 ]; then
        echo "The completed to-do list is empty"
    fi
}


# Add items to the to do list

todo_additem() {

    maxCount=0
    for filename in "$TODO_DIR/*"; do
        if [ -f $filename ]; then
            maxCount=$(($maxCount+1))
        fi
    done
    maxCount=$(($maxCount+1))
    newfile="$TODO_DIR/$maxCount"
    echo "$1" >> "$newfile"
    echo "---------" >> "$newfile"
    if [ $# -gt 1 ]; then
        echo "$2" >> "$newfile"
    fi
    chmod 700 "$newfile"
    echo "Item added to the list!"
}


# Mark an item as complete

todo_complete() {
    if [ -z $@ ]; then
        echo "No job to mark as complete"
    else
        task=$1
        job=$TODO_DIR/$1
        if ! [ -f $job ]; then
            echo "The task does not exist"
        else
            # Move the task from to-do to completed directory
            maxCount=0
            for file in $TODOC_DIR/*; do
                if [ -f $file ]; then
                    maxCount=$(($maxCount+1))
                fi
            done
            maxCount=$(($maxcount+1))
            newfile=$TODOC_DIR/$maxCount
            mv $job $newfile
            chmod 600 $newfile
            
            # Rename the files in the to-do folder
            for file in $TODO_DIR/*; do
                if [ -f $file ]; then
                    taskn="$(basename -- $file)"
                    if [ $taskn -gt $task ]; then
                        newFile=$TODO_DIR/$(($taskn-1))
                        mv $file $newFile
                    fi
                    chmod 600 $newFile
                fi
            done
        fi
    fi
}


# Display menu

display_menu() {
    echo "Welcome to to-do list manager! Here are your current items."
    todo_list_all
    
    echo "What would you like to do?"
    echo "Enter an item number to see more information, or:"
    echo "A: Mark an item as completed"
    echo "B: Add a new item"
    echo "C: See completed items"
    echo "Q: Quit"
}


# Main program

init

#Check command line arguments
if [ -z $1 ]; then
    #if there are no command line arguemnts, go to menu
    while true; do
        clear
        display_menu
        read -p "Enter choice: " choice
        if [[ $choice =~ ^[0-9]+$ ]]; then
            todo_list_detail $choice
        else
            case $choice in
            "A")
                read -p "Enter the item number completed: " icomplete
                todo_complete $icomplete
                ;;
             "B")
                read -p "Enter the title of the new item: " title
                read -p "Enter the details of the new item: " details
                todo_additem "$title" "$details"
                ;;
            "C")
                todo_list_comp
                ;;
            "Q")
                exit
                ;;
            *)
                echo "Invalid Choice"
            esac
        fi
        read -p "Press ENTER to Continue " input
    done
else
    # process command line arguments
    case $1 in
    "add")
        # Check to see if a pipe exists on stdin.
        if [ $# = 1 ]; then
            read -p "Enter the title of the new item: " title
            read -p "Enter the details of the new item: " details
            todo_additem "$title" "$details"
        else
            title="$2"
            if [ -p /dev/stdin ]; then
                read details
            else
                read -p "Enter the details of the new item: " details
            fi
            todo_additem "$title" "$details"
        fi
        ;;
    "list")
        # Check for more arguments
        if [ -z $2 ]; then
            todo_list_all
        else
            if [ $2 = "completed" ]; then
                todo_list_comp
            else
                show_help
            fi
        fi
        ;;
    "complete")
        if [ -z $2 ]; then
            read -p "Enter the item number completed: " icomplete
        else
            icomplete=$2
        fi
        todo_complete $icomplete
        ;;
    "help")
        show_help
        ;;
    *)
        echo "Use 'todo help' for help"
        ;;
    esac
fi
