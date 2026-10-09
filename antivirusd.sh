#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 dir malicious_dir interval-secs"
    exit 1
fi

DIR="$1"
MALICIOUS_DIR="$2"
INTERVAL="$3"

mkdir -p "$DIR"
mkdir -p "$MALICIOUS_DIR"

scan_the_directory() {
    for filepath in "$DIR"/*; do
        [ -e "$filepath" ] || continue
        [ -f "$filepath" ] || continue

        filename=$(basename "$filepath")
        is_malicious=0

        case "$filename" in
            *.exe|*.bat|*.vbs|*.scr|*.ps1)
                is_malicious=1
                ;;
        esac
        if [ "$is_malicious" -eq 0 ]; then
            if grep -qiE 'virus|trojan|malware|worm|ransomware' "$filepath" 2>/dev/null; then
                is_malicious=1
            fi
        fi

        if [ "$is_malicious" -eq 1 ]; then
            echo "$filename is malicious and it is DELETED"
            cp "$filepath" "$MALICIOUS_DIR/"
            rm -f "$filepath"
        fi
    done

    ls -l "$DIR" > directory-info.last
}

if [ ! -f "directory-info.last" ]; then
    scan_the_directory
else
    ls -l "$DIR" > directory-info.last
fi

while true; do
    sleep "$INTERVAL"
    ls -l "$DIR" > directory-info.new
    if ! cmp -s directory-info.last directory-info.new; then
        scan_the_directory
    fi
done