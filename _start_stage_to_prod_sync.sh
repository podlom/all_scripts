#!/usr/bin/env bash
set -Eeuo pipefail

#
# @author Taras Shkodenko taras@shkodenko.com
#
# Set up local and remote credentials
LOCAL_WP_PATH="/home/wpe-user/sites/asianlegacystg" # Change to your WordPress directory path
LOCAL_UPLOADS_PATH="${LOCAL_WP_PATH}/wp-content/uploads" # Local uploads directory path
DB_BACKUP_PATH="/home/wpe-user/sites/asianlegacystg/wp-content/_db_backups" # Local backup directory
DB_RESTORE_REMOTE_PATH="/home/wpe-user/sites/asianlegacystg/wp-content/_db_backups/nas/content/live/asianlegacylib/wp-content/_db_backups"
DB_BACKUP_NAME="_wp_stage_backup_$(date +%F_%H-%M-%S).sql" # Backup file name with a timestamp
TAR_BACKUP_NAME="${DB_BACKUP_NAME}.tar.bz2"
REMOTE_USER="wpe-user" # Remote server username on prod
REMOTE_HOST="asianlegacylib.ssh.wpengine.net" # Remote server host on prod
REMOTE_PATH="/nas/content/live/asianlegacylib" # Remote backup directory on prod
REMOTE_UPLOADS_PATH="/nas/content/live/asianlegacylib/wp-content/uploads" # Remote uploads directory path on prod
REMOTE_SSH_PORT="22" # Default SSH port is 22, change if it's different on prod
REMOTE_WP_PATH="/nas/content/live/asianlegacylib" # Change to your WordPress directory path on prod
REMOTE_DB_BACKUP_PATH="/nas/content/live/asianlegacylib/wp-content/_db_backups" # Local backup directory
REMOTE_DB_BACKUP_NAME="_wp_prod_backup_$(date +%F_%H-%M-%S).sql" # Backup file name with a timestamp


# Check if the directory exists
if [ -d "${DB_BACKUP_PATH}" ]; then
    rm -fv "${DB_BACKUP_PATH}/*.sql"
    printf "Display directory listing in ${DB_BACKUP_PATH}.\n"
    ls -alh "${DB_BACKUP_PATH}"
else
    # Make sure the local db backups directory exists
    echo "Directory does not exist. Creating directory ${DB_BACKUP_PATH}..."
    mkdir -pv "${DB_BACKUP_PATH}"
fi

# Navigate to the WordPress installation directory
cd "${LOCAL_WP_PATH}"
# Print working directory
pwd
# Display current directory listing
ls -alh

# Create a backup of the WordPress database using WP-CLI
wp db export "${DB_BACKUP_PATH}/${DB_BACKUP_NAME}"
tar cpjvf "${DB_BACKUP_PATH}/${TAR_BACKUP_NAME}" "${DB_BACKUP_PATH}/${DB_BACKUP_NAME}"
ls -alh "${DB_BACKUP_PATH}"


# Pass log file name sswith a prod SQL dump file name in it
# Check if an argument was provided
if [ "$#" -ne 1 ]; then
    echo "Error. Usage: $0 /path/to/your/file.sql.tar.bz2"
    exit 1
fi

# The first required argument is the dump.sql.tar.bz2 file name
FILE_PATH="$1"

# Check if the file exists
if [ -f "${DB_BACKUP_PATH}/${FILE_PATH}" ]; then
    cd "${DB_BACKUP_PATH}"
    pwd
    ls -alh
    tar xjvf "${DB_BACKUP_PATH}/${FILE_PATH}"

    STRIPPED_NAME="${FILE_PATH%.tar.bz2}"
    printf "Display directory listing in ${DB_RESTORE_REMOTE_PATH}...\n"
    ls -alh "${DB_RESTORE_REMOTE_PATH}"

    if [ -f "${DB_RESTORE_REMOTE_PATH}/${STRIPPED_NAME}" ]; then
        printf "Starting DB import from SQL dump file ${DB_RESTORE_REMOTE_PATH}/${STRIPPED_NAME}...\n"
        wp db import "${DB_RESTORE_REMOTE_PATH}/${STRIPPED_NAME}"

        printf "Fix website URLs...\n"
        wp db query < "${DB_RESTORE_REMOTE_PATH}/_update_prod_to_stage_option_urls.sql"

        echo "Well done at:"
        date
    else
        echo "Error: The file at path '${DB_RESTORE_REMOTE_PATH}/${STRIPPED_NAME}' does no exists."
    fi
else
    echo "Error: The file at path '${DB_RESTORE_REMOTE_PATH}/${FILE_PATH}' does not exist."
fi
