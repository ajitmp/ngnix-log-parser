#!/usr/bin/env bash

set -e

##
# Combine all Nginx Access Log files, into one log file. Starting with the
# oldest log file(s) at the bottom, with the newest log file(s) on top.
#
# Useful for exporting into log analyzers, or bulk importing into tools like
# Splunk.
#
# Log files names are expected to have the following format:
#
#   access.log[rotate-increment-count]
#
# Example:
#
#   access.log
#   access.log.0
#   access.log.1
#   access.log.2
#   ...
#   ...
#   ...
#   Would be combined to:
#   >> combined_11302017-04022018.log
##

nginx_access_log_path=/var/log/nginx
cd $nginx_access_log_path

# Find the oldest and the newest access log files:
oldest_file_name=$(find . -maxdepth 1 -type f -name 'access.lo*' | cut -c3- |xargs ls -tr | head -1)
newest_file_name=$(find . -maxdepth 1 -type f -name 'access.lo*' \( ! -iname ".*" \) | cut -c3- | xargs ls -t | head -1)
oldest_file_date=$(date -r "$oldest_file_name" +%m%d%Y)
newest_file_date=$(date -r "$newest_file_name" +%m%d%Y)

combined_file_name="combined_${oldest_file_date}-${newest_file_date}.log"
[ -f "$combined_file_name" ] && rm -f "$combined_file_name"

echo "> Combining Nginx Access Logs..."
echo
access_logs=$(ls -1t access.lo*)
for access_log in ${access_logs}; do
    echo "- ${access_log}"
    cat "${access_log}" >> "${combined_file_name}"
done

echo
echo "Successfully combined Nginx Access Log files from '$oldest_file_date' through '$newest_file_date' to:"
echo "${nginx_access_log_path}/${combined_file_name}"
