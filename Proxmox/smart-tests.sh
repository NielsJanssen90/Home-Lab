#!/bin/bash

# Drives to test
drives=("/dev/sda" "/dev/sdb" "/dev/sdc" "/dev/sdd" "/dev/nvme0n1" "/dev/nvme1n1")

# Log file location
logfile="/var/log/smart-test.log"
errorlog="/var/log/smart-test-errors.log"

# Clear the log files for a fresh start
: > "$logfile"
: > "$errorlog"

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

# Function to check SMART results for issues
check_smart_results() {
    local drive=$1
    local result=$(smartctl -H "$drive" | grep -i "SMART overall-health self-assessment test result")
    
    # Check if the test result indicates an issue
    if [[ "$result" != *"PASSED"* ]]; then
        echo "[$date] WARNING: SMART Test failed on $drive!" >> "$errorlog"
        echo "Details:" >> "$errorlog"
        smartctl -a "$drive" >> "$errorlog"
        return 1
    fi
    return 0
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
        sleep 6000 # wait 10 minutes between each test
    done
fi

# Wait for tests to finish and collect results
echo "[$date] Collecting SMART test results..." >> "$logfile"
error_found=0

for drive in "${drives[@]}"; do
    echo "[$date] SMART Results for $drive:" >> "$logfile"
    smartctl -a "$drive" >> "$logfile"
    
    # Check SMART results and update error flag if an issue is found
    check_smart_results "$drive" || error_found=1
done

# Email the results if an error was found
if [ "$error_found" -eq 1 ]; then
    echo "Errors found in SMART tests, sending email." >> "$logfile"
    # Use base64 as a fallback if uuencode is not available
    (cat "$errorlog"; base64 "$errorlog") | mail -s "SMART Test Error Report" nielsjanssen.1990@gmail.com
else
    echo "All SMART tests passed successfully, no email will be sent." >> "$logfile"
fi
