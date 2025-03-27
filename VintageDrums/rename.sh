#!/bin/bash

# Ensure the script is executed in the directory containing the files
# or provide the directory path as an argument.
DIR=${1:-.}

# Navigate to the directory
cd "$DIR" || exit

# Initialize the index
i=0

# Iterate over all files in the directory
for file in *; do
  # Skip if it's not a regular file
  if [[ -f $file ]]; then
    # Format the new filename with the index and original filename
    new_name=$(printf "%02d_%s" "$i" "$file")

    # Rename the file
    mv "$file" "$new_name"

    # Increment the index
    ((i++))
  fi
done

echo "Renaming complete!"

