#!/bin/bash

# Create libs directory if it doesn't exist
mkdir -p libs

# Array of repository paths and their specific commits
# If the library is updated and you want to pull in the changes, point this file to the relavent commit by changing the commit number.
declare -A repos=(
  # Folder name  |    Repository Link |   Commit ID
  ["math"]="PruzisBdg/math-small-C|d097a84322ecb14835407b04e64275a9d86e64d7"
  ["util"]="PruzisBdg/util-small-C|68c4f222c7bbe2ea06f36b633f1a17df00ecc211" 
  ["tiny2"]="PruzisBdg/tiny2|7b5c5a1fa6e24cea577b082bf6b1fd961e21be17"
  ["arith"]="PruzisBdg/arith-small-C|f2f6ba8933cbabfff9b85e8ceac55266effb64a7"
  ["libs_common"]="PruzisBdg/spj_libs_shared|ab8a6c9bee770380b8bac9137646f2cb2d917406"
)


# Base GitHub URL
GITHUB="https://github.com"

echo "Cloning/pulling libraries into libs/ folder..."

# Process each repository
for folder in "${!repos[@]}"; do
  IFS='|' read -ra repo_info <<< "${repos[$folder]}"
  repo_path="${repo_info[0]}"
  commit_ref="${repo_info[1]}"
  target_dir="libs/$folder"
  branch_name="fixed-${commit_ref:0:7}"  # Creates branch like "fixed-58e0a98"
  
  if [ -d "$target_dir" ]; then
    echo "[$folder] Repository exists - updating to specific commit..."
    (
      cd "$target_dir"
      git fetch origin
      # Create or reset branch to point to our commit
      if git show-ref --quiet "refs/heads/$branch_name"; then
        git checkout "$branch_name"
        git reset --hard "$commit_ref"
      else
        git checkout -b "$branch_name" "$commit_ref"
      fi
    )
  else
    echo "[$folder] Cloning $repo_path and checking out $commit_ref..."
    git clone "$GITHUB/$repo_path.git" "$target_dir"
    (
      cd "$target_dir"
      git checkout -b "$branch_name" "$commit_ref"
    )
  fi
done



set -euo pipefail
# Configuration  UPDATE REVISION IF YOU WANT TO PULL IN CHANGES!!!!!
URL="https://badger-meter.svn.beanstalkapp.com/aquarius/"
REVISION="347"
DEST="libs/aquarius"

# Save the current directory
ORIGINAL_DIR=$(pwd)

# Function to run commands in login shell
run_in_login_shell() {
    local cmd="$1"
    bash.exe --login -c "cd \"$ORIGINAL_DIR\" && $cmd"
}

 

# Return to original directory
cd "$ORIGINAL_DIR"

echo "Checking out Aquarius repo at r$REVISION"
echo "URL:  $URL"
echo "DEST: $DEST"

# Remove destination folder if it exists
if [ -d "$DEST" ]; then
  echo "Removing existing folder: $DEST"
  rm -rf "$DEST"
fi

# Run the checkout in a login shell
run_in_login_shell "svn checkout -r \"$REVISION\" \"$URL\" \"$DEST\""

echo "All libraries updated to specified commits in libs/"