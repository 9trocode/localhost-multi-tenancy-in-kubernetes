!/bin/bash

set -eu

# Change to the directory of the script
cd "$(dirname "$0")"

# Define the scripts to run
SETUP_SCRIPTS=(
    "./capsule/scripts/e2e.sh"
    # "./kiosk/scripts/e2e.sh"
    # "./kubezoo/scripts/e2e.sh"
)

# Function to run a script if it exists
run_script() {
    echo "Checking for script: $1"
    if [ -f "$1" ]; then
        echo "Running $1..."
        if bash "$1"; then
            echo "$1 completed successfully."
        else
            echo "Warning: $1 failed with exit code $?."
        fi
    else
        echo "Warning: $1 not found. Skipping..."
        echo "Current directory: $(pwd)"
        echo "Directory contents:"
        # ls -R
    fi
    echo
}

# Main execution
echo "Starting setup process..."
echo "Current working directory: $(pwd)"
echo "Directory contents:"
ls

for script in "${SETUP_SCRIPTS[@]}"; do
    run_script "$script"
done

echo "Setup process completed."