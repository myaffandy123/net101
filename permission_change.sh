#!/bin/bash

# Display the usage script
usage() {
    echo "Usage: $0 [parent_directory] [--edit|-e | --read|-r]"
    exit 1
}

# Check minimal argument count
if [ $# -lt 2 ]; then
    usage
fi

# Check argument
parent_directory="$1"
shift

edit_mode=false
read_mode=false

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -e|--edit)
            if [ "$read_mode" = true ]; then
                echo "Error: --edit (-e) and --read (-r) can't be used together."
                usage
            fi
            edit_mode=true
            ;;
        -r|--read)
            if [ "$edit_mode" = true ]; then
                echo "Error: --edit (-e) and --read (-r) can't be used together."
                usage
            fi
            read_mode=true
            ;;
        *)
            echo "Invalid argument: $1"
            usage
            ;;
    esac
    shift
done

# Check parent directory is valid
if [ ! -d "$parent_directory" ]; then
    echo "Error: $parent_directory directory not found."
    exit 1
fi

# Looping for each folder inside parent directory
for folder in "$parent_directory"/*; do
    if [ -d "$folder" ]; then
        file_path="$folder/frr.conf"
        
        if [ -f "$file_path" ]; then
            if [ "$edit_mode" = true ]; then
                # Change owner to current user
                sudo chown $(whoami):$(whoami) "$file_path"
                # Change permission to rw-rw-rw-
                sudo chmod 666 "$file_path"
                echo "Successfully update $file_path (edit mode)"
            elif [ "$read_mode" = true ]; then
                # Change owner to frr dan group to frr
                sudo chown frr:frr "$file_path"
                # Change permission to rw-r-----
                sudo chmod 640 "$file_path"
                echo "Successfully update $file_path (read mode)"
            fi
        else
            echo "File $file_path not found in folder $folder"
        fi
    fi
done
