#!/usr/bin/env bash

# Enter ILIAS username and password here
# Modify here
ILIAS_USERNAME="st123456"
ILIAS_PASSWORD="12345689"

# Choose a relative path to store the file in every data directory or an absolute path for one single file
# Keep it like this if you're not sure
HISTORY_FILE=.il-history

# Don't modify
source IliasDownload.sh

do_login

# Insert the folders you want to fetch here.
# Take the id of the folder/course out of the URL, e.g.
#
# https://ilias3.uni-stuttgart.de/go/crs/3633981
#                                    ^^^^^^^^^^^
# or
#
# https://ilias3.uni-stuttgart.de/go/fold/3633981
#                                    ^^^^^^^^^^^^
#
# You find this link at the bottom of every folder page.
# Subfolders and exercises are automatically downloaded, too.
# You need to use absolute paths for local folders!
#
# You can download the whole course or just specific folders from a course.

# Preset your Homefolder
MY_STUDIES_FOLDER="/A/B/C"

# Copy for every course/folder you want to download
# Modify here
fetch_folder "crs/3633981" "$MY_STUDIES_FOLDER/Modellierung"

# Don't modify (awaiting completion of all fetch_folders)
wait
do_logout
rm $COOKIE_PATH

# Don't modify (printing final stats)
print_stat
sleep 10
