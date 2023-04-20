#!/bin/bash

input_url=${1:-"https://hl7.org/fhir/package-feed.xml"}
wget $input_url -O package-feed.xml

# Create the cruft directory if it doesn't exist
mkdir -p cruft

# Extract all the guid URLs
urls=$(grep -oP '(?<=<guid isPermaLink="true">).*(?=</guid>)' package-feed.xml | tac)

# Loop through the URLs and perform the desired actions
for url in $urls; do
  echo "Processing $url"
  # Download package.tgz
  wget -q "$url" -O package.tgz

  # Extract the package
  mkdir -p package
  tar -xzf package.tgz -C package --strip-components=1

  # Edit package/package.json
  jq '.repository = "https://github.com/jmandel/registry" | .name |= "@jmandel/" + . | if has("dependencies") then .dependencies |= with_entries(if .key | (startswith("hl7.") or startswith("fhir.") or startswith("us.")) then .key |= "@jmandel/" + . else . end) else . end' package/package.json > package/package_modified.json
  mv package/package_modified.json package/package.json

  # npm publish the package
  # NOTE: This command might require authentication or additional options
  cd package
  npm publish
  cd ..

  # Encode the guid URL in a more readable way
  encoded_url=$(echo "$url" | sed 's|[:/.]|_|g')
  cruft_filename="cruft/package_${encoded_url}"

  # Move temp files to the cruft directory
  mv package "${cruft_filename}_dir"
  echo "$url" >> loaded.txt

done
