#!/bin/bash

# Set the Go source file and binary name
GO_SOURCE_FILE="main.go"
GO_BINARY="repo-security-scanner"

# Set the file containing the list of git repos
REPO_FILE="repos.txt"

# Build the Go binary
echo "Building binary..."
go build -o $GO_BINARY $GO_SOURCE_FILE

# Check if the binary was built successfully
if [[ ! -f $GO_BINARY ]]; then
  echo "Failed to build the Go binary."
  exit 1
fi

# Check if the repo file exists
if [[ ! -f $REPO_FILE ]]; then
  echo "Repo file not found: $REPO_FILE"
  exit 1
fi

# Loop through each line in the repo file
while IFS= read -r repo; do
  # Skip empty lines
  if [[ -z "$repo" ]]; then
    continue
  fi

  # Get the repo name
  repo_name=$(basename "$repo" .git)

  # Clone the repo
  echo "Cloning repo: $repo"
  git clone "$repo" "$repo_name"

  # Check if clone was successful
  if [[ ! -d "$repo_name" ]]; then
    echo "Failed to clone repo: $repo"
    continue
  fi

  # Navigate to the repo directory
  cd "$repo_name" || exit

  # Run git log -p and pipe to the Go binary
  echo "Scanning $repo_name"
  git log -p | "../$GO_BINARY"

  # Navigate back to the parent directory
  cd ..

  # Delete the local repo
  echo "Deleting repo: $repo_name"
  rm -rf "$repo_name"
done < "$REPO_FILE"

# Clean up the Go binary
echo "Cleaning up Go binary..."
rm -f $GO_BINARY

echo "Script completed."