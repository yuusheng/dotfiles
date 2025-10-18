#!/bin/bash

PACKAGE_FILE="./install.txt"

# homebrew
if ! command -v brew &>/dev/null; then
  echo "--- Installing Homebrew ---"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "--- Homebrew Package Installation ---"

while IFS= read -r PACKAGE; do
  # Trim leading and trailing whitespace from the package name
  PACKAGE=$(echo "$PACKAGE" | xargs)

  # Skip empty lines
  if [ -z "$PACKAGE" ]; then
    continue
  fi

  # Check if it's a comment/category line (starts with #)
  if [[ "$PACKAGE" =~ ^# ]]; then
    echo ""
    echo "--------------------------------------------------"
    echo "Processing Category: $PACKAGE"
    echo "--------------------------------------------------"
    continue
  fi

  # Install the package
  echo ">>> Installing: $PACKAGE ..."
  if brew install "$PACKAGE"; then
    echo ">>> $PACKAGE installed successfully!"
  else
    echo "!!! Failed to install $PACKAGE. Please check the error message!" >&2
  fi
  echo ""

done <"$PACKAGE_FILE"

echo "--- All Homebrew package installation attempts completed ---"

# rust
if ! command -v cargo &>/dev/null; then
  echo "--- Installing Rust ---"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi
