#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 dir malicious_dir"
    exit 1
fi

DIR="$1"
MALICIOUS_DIR="$2"
flag=1

while true; do
    files=()
    for f in "$MALICIOUS_DIR"/*; do
        [ -e "$f" ] || continue
        [ -f "$f" ] || continue
        files+=("$(basename "$f")")
    done

    total_files=${#files[@]}
    if [ "$total_files" -eq 0 ]; then
        if [ "$flag" -eq 1 ]; then
            echo "No malicious files to review."
        fi
        exit 0
    fi

    flag=0

    echo "Choose a file:"
    for i in "${!files[@]}"; do
        echo "$((i + 1)): ${files[$i]}"
    done

    printf "> "
    read -r file_choice

    if ! [[ "$file_choice" =~ ^[0-9]+$ ]] || [ "$file_choice" -lt 1 ] || [ "$file_choice" -gt "$total_files" ]; then
        continue
    fi

    selected_file="${files[$((file_choice - 1))]}"
    target_path="$MALICIOUS_DIR/$selected_file"

    echo "For $selected_file:"
    echo "1: Restore this file back into dir (it was a false positive)"
    echo "2: Permanently delete this file from malicious_dir (it was genuinely malicious)"
    echo "3: Go back"
    printf "> "
    read -r action

    case "$action" in
        1)
            mv "$target_path" "$DIR/$selected_file"
            echo "Restored $selected_file to $DIR."
            ;;
        2)
            rm -f "$target_path"
            echo "$selected_file permanently deleted."
            ;;
        3)
            continue
            ;;
        *)
            continue
            ;;
    esac
done