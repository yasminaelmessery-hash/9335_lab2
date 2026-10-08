#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <dir> <malicious_dir> <interval-secs>"
    exit 1
fi

DIR="$1"
MALICIOUS_DIR="$2"
INTERVAL="$3"

if [ ! -d "$DIR" ]; then
    echo "Error: Monitored directory '$DIR' does not exist."
    exit 1
fi

mkdir -p "$MALICIOUS_DIR"

LAST_SNAPSHOT="directory-info.last"
NEW_SNAPSHOT="directory-info.new"

EXTENSIONS=("exe" "bat" "vbs" "scr" "ps1")
KEYWORDS=("virus" "trojan" "malware" "worm" "ransomware")

scan_directory() {
    for filepath in "$DIR"/*; do
        [ -e "$filepath" ] || continue
        [ -f "$filepath" ] || continue

        filename=$(basename "$filepath")
        is_malicious=0

        file_ext="${filename##*.}"
        if [ "$file_ext" != "$filename" ]; then
            for ext in "${EXTENSIONS[@]}"; do
                if [ "$file_ext" = "$ext" ]; then
                    is_malicious=1
                    break
                fi
            done
        fi

        if [ "$is_malicious" -eq 0 ]; then
            for kw in "${KEYWORDS[@]}"; do
                if grep -qi "$kw" "$filepath" 2>/dev/null; then
                    is_malicious=1
                    break
                fi
            done
        fi

        if [ "$is_malicious" -eq 1 ]; then
            echo "$filename is malicious and it is DELETED"
            cp "$filepath" "$MALICIOUS_DIR/$filename"
            rm -f "$filepath"
        fi
    done
}

scan_directory
ls -l "$DIR" > "$LAST_SNAPSHOT"

while true; do
    sleep "$INTERVAL"

    ls -l "$DIR" > "$NEW_SNAPSHOT"

    if ! diff "$LAST_SNAPSHOT" "$NEW_SNAPSHOT" > /dev/null 2>&1; then
        scan_directory
        ls -l "$DIR" > "$LAST_SNAPSHOT"
    fi
done
