#!/usr/bin/env bash
set -Eeuo pipefail

#
# @author Taras Shkodenko taras@shkodenko.com
#
# Define server addresses and directories
STAGING_SERVER="asianlegacystg.ssh.wpengine.net"
PROD_SERVER="asianlegacylib.ssh.wpengine.net"
STAGING_DIR="/nas/content/live/asianlegacystg/wp-content/plugins/"
LOCAL_DIR="/home/shkodenko.t/_bk/2023_all/all_wpengine/stage/wp-content/"
LOCAL_DIR_PLUGINS="${LOCAL_DIR}plugins"
PROD_DIR="/nas/content/live/asianlegacylib/wp-content/"


echo "Sync WP theme from stage to prod has started at:"
date

# Step 1. Check if the local backup directory exists
if [ -d "${LOCAL_DIR}" ]; then
    printf "1. Local backup directory exists ${LOCAL_DIR}.\n"
    ls -alh "${LOCAL_DIR}"
else
    # Make the local directory if it does not exists
    echo "1. Local backup directory does not exists. Make directory ${LOCAL_DIR}..."
    mkdir -pv "${LOCAL_DIR}"
fi

# Step 2: Sync from Staging to Local backup directory
echo "2. Syncing from Staging Server to Local backup directory..."
rsync -avz --progress $STAGING_SERVER:$STAGING_DIR $LOCAL_DIR
date

# Check if rsync was successful
if [ $? -ne 0 ]; then
    echo "2. Failed to sync from Staging Server."
    exit 1
fi

# Step 3: Sync from Local backup directory to Production
echo "3. Sync from Local backup directory to Production..."
rsync -avz --progress $LOCAL_DIR_PLUGINS $PROD_SERVER:$PROD_DIR
date

# Check if rsync was successful
if [ $? -ne 0 ]; then
    echo "3. Failed to sync to Production Server."
    exit 1
fi

echo "Sync WP theme from stage to prod has finished at:"
date