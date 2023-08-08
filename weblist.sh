#!/bin/bash

# Function to scrape words from a URL
scrape_url() {
    local url="$1"
    local temp_file="$2"
    local page_content=$(curl -s "$url")
    grep -o -E '\b[[:alpha:]]+\b' <<< "$page_content" >> "$temp_file"
}

# Check the number of arguments provided
if [ $# -lt 2 ]; then
    echo "Usage: $0 <-u URL | -f URLs_file>"
    exit 1
fi

# Check if the -u or -f switch is provided
case "$1" in
    -u)
        if [ $# -ne 2 ]; then
            echo "Usage: $0 -u <URL>"
            exit 1
        fi
        url="$2"
        temp_file=$(mktemp)
        scrape_url "$url" "$temp_file"
        ;;
    -f)
        if [ $# -ne 2 ]; then
            echo "Usage: $0 -f <URLs_file>"
            exit 1
        fi
        urls_file="$2"
        if [ ! -f "$urls_file" ]; then
            echo "URLs file not found: $urls_file"
            exit 1
        fi
        temp_file=$(mktemp)
        while read -r url; do
            scrape_url "$url" "$temp_file"
        done < "$urls_file"
        ;;
    *)
        echo "Usage: $0 <-u URL | -f URLs_file>"
        exit 1
        ;;
esac

# Create the output file with no duplicates
output_file="output.txt"
sort -u "$temp_file" > "$output_file"

# Clean up the temporary file
rm "$temp_file"

echo "Scraped words with no duplicates have been saved to $output_file."
