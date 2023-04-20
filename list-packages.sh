# Set user and endpoint
user=jmandel
endpoint=/users/$user/packages


max_per_page=100

# Initialize temporary file for results
echo -n "" > packages.txt

# Set initial page number and loop flag
page=1

rm packages.txt

while true; do
  # Make API request for current page and append URLs to temporary file
  gh api -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" "$endpoint?package_type=npm&per_page=$max_per_page&page=$page" | jq -r 'map(.url)[]' > packages.tmp
  cat packages.tmp >> packages.txt

  # Check if the temporary file has reached the maximum number of lines
  echo "len $(wc -l < packages.tmp)"
  if [ $(wc -l < packages.tmp) -lt $max_per_page ]; then
    break
  fi

  # Increment page number and continue looping
  page=$((page + 1))
done

# Append results from temporary file to final output file and remove temporary file
rm packages.tmp
