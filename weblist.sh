#!/bin/bash

# Check if the -f switch is provided
if [[ "$1" != "-f" ]]; then
    echo "Usage: $0 -f <URLs_file>"
    exit 1
fi

# Get the URLs file provided as the next argument
urls_file="$2"

# Ensure a URLs file is provided
if [ -z "$urls_file" ]; then
    echo "Please provide a file containing URLs."
    exit 1
fi

# Temporary file to store scraped words
temp_file=$(mktemp)

# Loop through each URL in the file
while read -r url; do
    # Fetch the web page content using curl
    page_content=$(curl -s "$url")

    # Extract words using grep and append them to the temporary file
    grep -o -E '\b[[:alpha:]]+\b' <<< "$page_content" >> "$temp_file"
done < "$urls_file"

# Create the output file with no duplicates
output_file="output.txt"
sort -u "$temp_file" > "$output_file"

# Clean up the temporary file
rm "$temp_file"

echo "Wordlist from URL(s) have been saved to $output_file."
