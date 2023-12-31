#!/usr/bin/env bash
set -Eeuo pipefail

#
# @author Taras Shkodenko taras@shkodenko.com
#
# Define server addresses and directories
STAGING_SERVER="asianlegacystg.ssh.wpengine.net"
PROD_SERVER="asianlegacylib.ssh.wpengine.net"
REMOTE_DIR="/nas/content/live/asianlegacystg/wp-content/uploads/"
LOCAL_DIR="/home/shkodenko.t/_bk/2023_all/all_wpengine/stage/wp-content/"
LOCAL_DIR_UPLOADS="${LOCAL_DIR}uploads"
PROD_DIR="/nas/content/live/asianlegacylib/wp-content/"


echo "Sync WP uploads has started at:"
date

# Step 1. Check if the directory exists
if [ -d "${LOCAL_DIR}" ]; then
    printf "1. Local directory exists ${LOCAL_DIR}.\n"
    ls -alh "${DB_BACKUP_PATH}"
else
    # Make the local directory if it does not exists
    echo "1. Local directory does not exists. Make directory ${LOCAL_DIR}..."
    mkdir -pv "${LOCAL_DIR}"
fi

# Step 2: Sync from Staging to Local
echo "2. Syncing from Staging Server to Local..."
rsync -avz --progress $STAGING_SERVER:$REMOTE_DIR $LOCAL_DIR
date

# Check if rsync was successful
if [ $? -ne 0 ]; then
    echo "2. Failed to sync from Staging Server."
    exit 1
fi

# Step 3: Sync from Local to Production
echo "3. Syncing from Local to Production Server..."
rsync -avz --progress $LOCAL_DIR_UPLOADS $PROD_SERVER:$PROD_DIR
date

# Check if rsync was successful
if [ $? -ne 0 ]; then
    echo "3. Failed to sync to Production Server."
    exit 1
fi

echo "Sync WP uploads has finished at:"
date
