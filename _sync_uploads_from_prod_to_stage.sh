#!/usr/bin/env bash
set -Eeuo pipefail

#
# @author Taras Shkodenko taras@shkodenko.com
#
# Define server addresses and directories
STAGING_SERVER="asianlegacystg.ssh.wpengine.net"
PROD_SERVER="asianlegacylib.ssh.wpengine.net"
REMOTE_DIR="/nas/content/live/asianlegacystg/wp-content/uploads/"
LOCAL_DIR="/home/shkodenko.t/_bk/2023_all/all_wpengine/prod/wp-content/"
PROD_DIR="/nas/content/live/asianlegacylib/wp-content/uploads/"


echo "Sync WP uploads has started at:"
date

# Step 1. Check if the directory exists
if [ -d "${LOCAL_DIR}" ]; then
    printf "Local directory exists ${LOCAL_DIR}.\n"
    ls -alh "${LOCAL_DIR}"
else
    # Make the local directory if it does not exists
    echo "Local directory does not exists. Make directory ${LOCAL_DIR}..."
    mkdir -pv "${LOCAL_DIR}"
fi

# Step 2: Sync from Prod to Local
echo "Syncing from Prod Server to Local..."
rsync -avz --progress $PROD_SERVER:$PROD_DIR $LOCAL_DIR
date

# Check if rsync was successful
if [ $? -ne 0 ]; then
    echo "Failed to sync from Prod Server."
    exit 1
fi

# Step 3: Sync from Local to Staging
echo "Syncing from Local to Staging Server..."
rsync -avz --progress $LOCAL_DIR $STAGING_SERVER:$REMOTE_DIR
date

# Check if rsync was successful
if [ $? -ne 0 ]; then
    echo "Failed to sync to Staging Server."
    exit 1
fi

echo "Sync WP uploads has finished at:"
date
