#!/usr/bin/env bash
set -Eeuo pipefail

#
# @author Taras Shkodenko taras@shkodenko.com
#
# Set up local and remote credentials
LOCAL_WP_PATH="/nas/content/live/asianlegacylib" # Change to your WordPress directory path
LOCAL_UPLOADS_PATH="${LOCAL_WP_PATH}/wp-content/uploads" # Local uploads directory path
DB_BACKUP_PATH="${LOCAL_WP_PATH}/wp-content/_db_backups" # Local backup directory
DB_BACKUP_NAME="_wp_prod_backup_$(date +%F_%H-%M-%S).sql" # Backup file name with a timestamp
TAR_BACKUP_NAME="${DB_BACKUP_NAME}.tar.bz2" # Tar Backup file name with a timestamp


# Make sure the local db backups directory exists
mkdir -pv "${DB_BACKUP_PATH}"
# Display db backups directory
printf "Display directory listing in ${DB_BACKUP_PATH}.\n"
ls -alh "${DB_BACKUP_PATH}"
# Remove all SQL backup files in folder
rm -fv "${DB_BACKUP_PATH}/*.sql"

# Navigate to the WordPress installation directory
cd "${LOCAL_WP_PATH}"
# Print working directory
pwd
# Display current directory listing
ls -alh

# Create a backup of the WordPress database using WP-CLI
wp db export "${DB_BACKUP_PATH}/${DB_BACKUP_NAME}"

# Check if WP-CLI successfully created the backup
if [ -f "${DB_BACKUP_PATH}/${DB_BACKUP_NAME}" ]; then
    printf "Database backup was created successfully.\n"

    # Make tar archive of SQL file
    tar cpjvf "${DB_BACKUP_PATH}/${TAR_BACKUP_NAME}" "${DB_BACKUP_PATH}/${DB_BACKUP_NAME}"

    echo "Well done at:"
    date

    # Show local db backup file listing
    ls "${DB_BACKUP_PATH}/${TAR_BACKUP_NAME}"
else
    echo "Failed to create database backup."
    exit 1
fi
