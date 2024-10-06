#!/bin/bash
set -euo pipefail

# Change to the directory of the script
cd "$(dirname "$0")"

# Define the scripts to run
SETUP_SCRIPTS=(
    "./capsule/scripts/install.sh"
    "./kiosk/scripts/install.sh"
    "./kubezoo/scripts/install.sh"
)

# Function to run a script if it exists
run_script() {
    local script="$1"
    echo "Checking for script: $script"
    if [ -f "$script" ]; then
        echo "Running $script..."
        if bash "$script"; then
            echo "$script completed successfully."
        else
            local exit_code=$?
            echo "Error: $script failed with exit code $exit_code."
            return $exit_code
        fi
    else
        echo "Warning: $script not found. Skipping..."
        echo "Current directory: $(pwd)"
        echo "Directory contents:"
        ls -la
    fi
    echo
}

# Main execution
main() {
    echo "Starting setup process..."
    echo "Current working directory: $(pwd)"
    echo "Directory contents:"
    ls -la

    local overall_exit_code=0
    for script in "${SETUP_SCRIPTS[@]}"; do
        if ! run_script "$script"; then
            overall_exit_code=1
            echo "Error encountered in $script. Continuing with next script..."
        fi
    done

    if [ $overall_exit_code -eq 0 ]; then
        echo "Setup process completed successfully."
    else
        echo "Setup process completed with errors."
    fi

    return $overall_exit_code
}

# Run main function
main
exit $?