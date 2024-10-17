#!/usr/bin/env bash

# IliasDownload.sh: A download script for ILIAS, an e-learning platform.
# Copyright (C) 2016 - 2018 Ingo Koinzer
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Für FH Aachen angepasst von Paul Krüger, Oktober 2020.
#
# Für Uni Stuttgart angepasst von Bjarne Spiekermann, September 2024.

if [ -z "$COOKIE_PATH" ]; then
    COOKIE_PATH=/tmp/ilias-cookies.txt
fi

# Load env-variables from config
. .config

# DON'T TOUCH FROM HERE ON

# TODO Die Variablen zählen falsch, da sie nicht zwischen den parallelen Prozessen geteilt werden.. Ein Logfile wäre vermutlich cooler.
ILIAS_DL_COUNT=0
ILIAS_IGN_COUNT=0
ILIAS_FAIL_COUNT=0
ILIAS_DL_NAMES=""
ILIAS_DL_FAILED_NAMES=""

check_config() {
    if [[ -z "${ILIAS_URL}" ]]; then
        echo "[Config] Ilias URL nicht gesetzt."
        exit 10 # terminate with error - ilias url missing
    else
        echo "[Config] ILIAS_URL=$ILIAS_URL"
    fi

    if [[ -z "${ILIAS_LOGIN_POST}" ]]; then
        echo "[Config] Ilias Login Pfad nicht gesetzt."
        exit 12 # terminate with error - ilias login get missing
    else
        echo "[Config] ILIAS_LOGIN_POST=$ILIAS_LOGIN_POST"
    fi

    if [[ -z "${ILIAS_HOME}" ]]; then
        echo "[Config] Ilias Home Pfad nicht gesetzt."
        exit 13 # terminate with error - ilias home missing
    else
        echo "[Config] ILIAS_HOME=$ILIAS_HOME"
    fi

    if [[ -z "${ILIAS_LOGOUT}" ]]; then
        echo "[Config] Ilias Logout Pfad nicht gesetzt."
        exit 14 # terminate with error - ilias logout missing
    else
        echo "[Config] ILIAS_LOGOUT=$ILIAS_LOGOUT"
    fi
}

check_credentials() {
    if [[ -z "${ILIAS_USERNAME}" ]]; then
        echo "[Config] Bitte Nutzername eingeben und Script erneut ausführen."
        exit 15 # terminate with error - ilias username missing
    else
        echo "[Config] ILIAS_USERNAME=$ILIAS_USERNAME"
    fi

    if [[ -z "${ILIAS_PASSWORD}" ]]; then
        echo "[Config] Bitte Passwort eingeben und Script erneut ausführen."
        exit 16 # terminate with error - ilias prefix missing
    else
        echo "[Config] ILIAS_PASSWORD=$(echo "$ILIAS_PASSWORD" | sed 's/./*/g')"
    fi
}

ilias_request() {
    curl -s -L -b "$COOKIE_PATH" -c "$COOKIE_PATH" $2 "$ILIAS_URL$1"
}

do_login() {
    if [ -f $COOKIE_PATH ]; then
        rm $COOKIE_PATH
    fi

    echo "Sending login information..."

    curl -s -L -c "$COOKIE_PATH" -X POST "$ILIAS_URL$ILIAS_LOGIN_POST" \
        -F "login_form/input_3/input_4=$ILIAS_USERNAME" \
        -F "login_form/input_3/input_5=$ILIAS_PASSWORD" >/dev/null

    result="$?"
    if [ "$result" -ne 0 ]; then
        echo "Failed sending login information: $result."
        exit 2
    fi

    echo "Checking if logged in..."
    local ITEMS=$(ilias_request "$ILIAS_HOME" | rg -oNP "ilDashboardMainContent")
    if [ -z "$ITEMS" ]; then
        echo "Home page check failed. Is your login information correct?"
        exit 3
    fi
}

function do_logout {
    echo "Logging out."
    ilias_request "$ILIAS_LOGOUT" >/dev/null
}

function get_filename {
    ilias_request "$1" "-I" | rg -oNP "Content-Description: \K(.*)" | tr -cd '[:print:]'
}

function fetch_exc {
    if [ ! -d "$2" ]; then
        echo "$2 is not a directory!"
        return
    fi
    cd "$2"
    if [ ! -f "$HISTORY_FILE" ]; then
        touch "$HISTORY_FILE"
    fi
    local HISTORY_CONTENT=$(cat "$HISTORY_FILE")

    echo "Fetching exc $1 to $2"

    local CONTENT_PAGE=$(ilias_request "ilias.php?baseClass=ilexercisehandlergui&cmdNode=cn:ns&cmdClass=ilObjExerciseGUI&cmd=showOverview&ref_id=$1&mode=all&from_overview=1")
    echo "$CONTENT_PAGE" >"$1.html"
    local EXERCISES=$(rg -oNP "<h4 class=\"il-item-title\">.?<a href=[^>]*ref_id=$1[^\"]*&ass_id=\K[0-9]*" "$1.html")
    rm "$1.html"
    for exc in $EXERCISES; do
        local CONTENT_PAGE=$(ilias_request "go/exc/$1/${exc}")
        echo $CONTENT_PAGE >"$1-${exc}.html"
        local ITEMS=$(rg -oNP "ilias.php[^>]*>Download" "$1-${exc}.html")
        local ITEMS=$(echo "$ITEMS" | rg -oNP "ilias.php[^\"]*")
        local EXC_NAME=$(rg -oNP "<div class=\"panel-title\">.?<h2>\K[^<]*" "$1-${exc}.html" | tr -d '[:blank:]')
        rm "$1-${exc}.html"
        for file in $ITEMS; do
            local FILENAME=$(echo $file | rg -oNP "&file=\K.*")
            local ECHO_MESSAGE="[$EXC_FOLDER_PREFIX$1] Check file $FILENAME ..."
            echo "$HISTORY_CONTENT" | grep "$file" >/dev/null
            if [ $? -eq 0 ]; then
                local ECHO_MESSAGE="$ECHO_MESSAGE exists"
                ((ILIAS_IGN_COUNT++))
            else
                local ECHO_MESSAGE="$ECHO_MESSAGE $FILENAME downloading..."
                if [ ! -d "$DIRECTORY" ]; then
                    mkdir "$EXC_NAME"
                fi
                ilias_request "$file" "--output-dir $EXC_NAME -O -J"
                local RESULT=$?
                if [ $RESULT -eq 0 ]; then
                    echo "$file" >>"$HISTORY_FILE"
                    ((ILIAS_DL_COUNT++))
                    local ECHO_MESSAGE="$ECHO_MESSAGE done"
                    ILIAS_DL_NAMES="${ILIAS_DL_NAMES} - ${FILENAME}
                    "
                else
                    local ECHO_MESSAGE="$ECHO_MESSAGE failed: $RESULT"
                    ((ILIAS_FAIL_COUNT++))
                    ILIAS_DL_FAILED_NAMES="${ILIAS_DL_NAMES} - ${FILENAME} (failed: $RESULT)
                    "
                fi
            fi
            echo "$ECHO_MESSAGE"
        done
    done

}

function fetch_folder {
    if [ ! -d "$2" ]; then
        echo "$2 is not a directory!"
        return
    fi
    cd "$2"
    if [ ! -f "$HISTORY_FILE" ]; then
        touch "$HISTORY_FILE"
    fi
    local HISTORY_CONTENT=$(cat "$HISTORY_FILE")

    echo "Fetching $1 to $2"

    echo "$1" | rg -oNP "^(fold|crs)/[0-9]*$" >/dev/null
    if [ $? -eq 0 ]; then
        local CONTENT_PAGE=$(ilias_request "go/$1")
    else
        return
    fi

    # Fetch Subfolders recursive (async)
    # somewhat ugly but for some reason piping didn't work
    echo $CONTENT_PAGE >"$2.html"
    local FOLDERS=$(rg -oNP "<h[34] class=\"il_ContainerItemTitle\">.?<a href=\"${ILIAS_URL}\Kgo/fold/[0-9]*" "$2.html")
    for folder in $FOLDERS; do
        local FOLDER_NAME=$(rg -oNP "<h[34] class=\"il_ContainerItemTitle\">.?<a href=\"${ILIAS_URL}${folder}\"[^>]*>\K[^<]*" "$2.html" | tr -d '[:blank:]')

        # Replace / by - character
        local FOLDER_NAME=$(echo "${FOLDER_NAME//\//-}" | head -1)
        echo "Entering folder $FOLDER_NAME"
        local FOLD_NUM=$(echo "$folder" | rg -oNP "go/\K.*")
        if [ ! -e "$2/$FOLDER_NAME" ]; then
            mkdir "$2/$FOLDER_NAME"
        fi
        fetch_folder "$FOLD_NUM" "$2/$FOLDER_NAME" &
    done

    # Files
    local FILES=$(rg -oNP "<h[34] class=\"il_ContainerItemTitle\">.?<a href=\"${ILIAS_URL}\Kgo/file/[0-9]*/download" "$2.html")
    for file in $FILES; do
        local DO_DOWNLOAD=1
        local NUMBER=$(echo "$file" | rg -oNP "[0-9]*")
        local ECHO_MESSAGE="[$1-$NUMBER]"

        # find the box around the file we are processing.
        local ITEM=$(rg -oNP "<h[34] class=\"il_ContainerItemTitle\"><a href=\"${ILIAS_URL}${file}.*<div style=\"clear:both;\"></div>")
        # extract version information from file. (Might be empty)
        # TODO not working
        local VERSION=$(echo "$ITEM" | rg -oNP '(?<=<span class=\"il_ItemProperty\"> ).*?(?=&nbsp;&nbsp;</span>.*)' "$2.html") | sed -n '3p'
        # build fileId
        local FILEID=$(echo "$file $VERSION" | xargs)

        echo "$HISTORY_CONTENT" | grep "$FILEID" >/dev/null
        if [ $? -eq 0 ]; then

            # If ITEM contains text geändert we must download
            echo "$ITEM" | grep "geändert" >/dev/null
            if [ $? -eq 0 ]; then
                local FILENAME=$(get_filename "$file")
                local ECHO_MESSAGE="$ECHO_MESSAGE $FILENAME changed"
                local PART_NAME="${FILENAME%.*}"
                local PART_EXT="${FILENAME##*.}"
                local PART_DATE=$(date +%Y%m%d-%H%M%S)
                mv "$FILENAME" "${PART_NAME}.${PART_DATE}.${PART_EXT}"
            else
                local ECHO_MESSAGE="$ECHO_MESSAGE exists"
                ((ILIAS_IGN_COUNT++))
                DO_DOWNLOAD=0
            fi
        fi
        if [ $DO_DOWNLOAD -eq 1 ]; then
            local FILENAME=$(get_filename "$file")

            ## Check if a local file with the same name exists. If so, it must be renamed. (This can happen when files on Ilias are not updated but deleted and re-uploaded.)
            if [[ -f "$FILENAME" ]]; then
                local ECHO_MESSAGE="$ECHO_MESSAGE $FILENAME new"
                local PART_NAME="${FILENAME%.*}"
                local PART_EXT="${FILENAME##*.}"
                local PART_DATE=$(date +%Y%m%d-%H%M%S)
                mv "$FILENAME" "${PART_NAME}.${PART_DATE}.${PART_EXT}"
            fi

            local ECHO_MESSAGE="$ECHO_MESSAGE $FILENAME downloading..."

            ilias_request "$file" "-O -J"
            local RESULT=$?
            if [ $RESULT -eq 0 ]; then
                echo "$FILEID" >>"$HISTORY_FILE"
                ((ILIAS_DL_COUNT++))
                local ECHO_MESSAGE="$ECHO_MESSAGE done"
                ILIAS_DL_NAMES="${ILIAS_DL_NAMES} - ${FILENAME}\n"
            else
                local ECHO_MESSAGE="$ECHO_MESSAGE failed: $RESULT"
                ((ILIAS_FAIL_COUNT++))
                ILIAS_DL_FAILED_NAMES="${ILIAS_DL_NAMES} - ${FILENAME} (failed: $RESULT)\n"
            fi
        fi

        ECHO_MESSAGE=$(echo $ECHO_MESSAGE | xargs)
        echo "$ECHO_MESSAGE"
    done

    # Exercises
    local ITEMS=$(rg -oNP "<h[34] class=\"il_ContainerItemTitle\">.?<a href=\"${ILIAS_URL}\Kgo/exc/[0-9]*" "$2.html")

    for exc in $ITEMS; do
        local EXC_NAME=$(rg -oNP "<h[34] class=\"il_ContainerItemTitle\">.?<a href=\"${ILIAS_URL}${exc}\"[^>]*>\K[^<]*" "$2.html" | tr -d '[:blank:]')

        # Replace / character
        local EXC_NAME=${EXC_NAME//\//-}
        echo "Entering exc $EXC_NAME"
        local EXC_NUM=$(echo "$exc" | rg -oNP "go/exc/\K[0-9]*")
        if [ ! -e "$2/$EXC_FOLDER_PREFIX-$EXC_NAME" ]; then
            mkdir "$2/$EXC_FOLDER_PREFIX-$EXC_NAME"
        fi
        fetch_exc "$EXC_NUM" "$2/$EXC_FOLDER_PREFIX-$EXC_NAME"
    done
    rm "$2.html"

    wait

}

function print_stat() {
    echo
    echo "Downloaded $ILIAS_DL_COUNT new files, ignored $ILIAS_IGN_COUNT files, $ILIAS_FAIL_COUNT failed."
    printf "$ILIAS_DL_NAMES"

    if [ ! -z "$ILIAS_DL_FAILED_NAMES" ]; then
        echo "Following downloads failed:"
        printf "$ILIAS_DL_FAILED_NAMES"
    fi
}

check_grep_availability
check_config
check_credentials
