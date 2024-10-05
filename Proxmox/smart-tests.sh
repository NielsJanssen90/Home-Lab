#!/bin/bash

# Drives to test
drives=("/dev/sda" "/dev/sdb" "/dev/sdc" "/dev/sdd" "/dev/nvme0n1" "/dev/nvme1n1")

# Log file location
logfile="/var/log/smart-test.log"

# Clear the log file for a fresh start
: > "$logfile"

# Get current date for logging
date=$(date '+%Y-%m-%d %H:%M:%S')

# Function to run the smart test
run_test() {
    local drive=$1
    local test_type=$2
    echo "[$date] Running $test_type test on $drive" >> "$logfile"
    smartctl --test="$test_type" "$drive" >> "$logfile" 2>&1
    echo "[$date] Test started on $drive" >> "$logfile"
}

# Run short test (weekly)
if [ "$1" == "short" ]; then
    for drive in "${drives[@]}"; do
        run_test "$drive" short
        sleep 600 # wait 10 minutes between each test
    done
fi

# Run long test (monthly)
if [ "$1" == "long" ]; then
    for drive in "${drives[@]}"; do
        run_test "$drive" long
        sleep 6000 # wait 1 hour between each test
    done
fi

# Wait for tests to finish and collect results
echo "[$date] Collecting SMART test results..." >> "$logfile"
for drive in "${drives[@]}"; do
    echo "[$date] SMART Results for $drive:" >> "$logfile"
    smartctl -a "$drive" >> "$logfile"
done

# Email the results
echo "SMART Test Results" | mail -s "SMART Test Results" -A "$logfile" nielsjanssen.1990@gmail.com
