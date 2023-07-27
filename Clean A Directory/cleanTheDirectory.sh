#!/bin/zsh
# name: cleanTheDirectory.sh
# Creator: Brian Gullen for Rocket Companies 2022-07-22
# Description: Checks specified directory for files over a certain size, converts to bytes, checks file size and removes if applicable.
# Notes: Inputes 4, 5, & 6 are required which specify directory, file size and file unit type (G, M, K or b)


## <-- variables --> ##

[[ -z "${4}" ]] && { echo "ERROR: Nothing set in \$4. REQUIRED: Directory to be checked. Exiting."; exit 1; } || dirToClean="${4}"
[[ -z "${5}" ]] && { echo "ERROR: Nothing set in \$5. REQUIRED: Minimum file size to be checked against. Exiting."; exit 1; } || fileSizeMax="${5}"
[[ -z "${6}" ]] && { echo "ERROR: Nothing set in \$6. REQUIRED: File size unit (G, M, K or b). Exiting."; exit 1; } || fileUnitType="${6}"


## <-- functions --> ##

function checkTheDir () {
getTheBigFiles="$(find "$dirToClean" -type f -size +${fileSizeMax}${fileUnitType} | awk -F/ '{print $NF}')"
echo "Checking for files larger than ${fileSizeMax}${fileUnitType} in $dirToClean."
if [[ -z "$getTheBigFiles" ]]
    then
        echo "No large files found to remove. Exiting."
        exit 0
    else
        echo "Found large files to remove. Let's proceed."
fi
}

function convertToBytes () {
case "$fileUnitType" in
G)
echo "Converting file size unit from Gigabtyes to Bytes"
    fileSizeBytes="$((fileSizeMax*1000000000))"
;;
M)
echo "Converting file size unit from Megabytes to Bytes"
    fileSizeBytes="$((fileSizeMax*1000000))"
;;
K)
echo "Converting file size unit from Kilobytes to Bytes"
    fileSizeBytes="$((fileSizeMax*1000))"
;;
b)
echo "File size unit is already in bytes. No need to convert"
    fileSizeBytes="$fileSizeMax"
;;
*)
echo "Invalid file size type provided. Exiting"
exit 1
;;
esac
}

function cleanTheDir () {
while read -r FILE
    do
    echo "Found potential file to remove $FILE. Checking..."
    allTheBigFiles+=("$FILE")
    done < <( echo "$getTheBigFiles" )
for bigFile in "${allTheBigFiles[@]}"
    do
        fileSize="$( stat -f %z "$dirToClean"/"$bigFile" )"
        echo "$bigFile is $fileSize bytes"
        if [[ "$fileSize" -ge "$fileSizeBytes" && -f "${dirToClean}/${bigFile}" ]]
            then
                echo "$bigFile is more than $fileSizeBytes bytes. Removing..."
                    if rm -rf "$dirToClean"/"$bigFile"
                        then
                            echo "Successfully removed $dirToClean/$bigFile."
                        else
                            echo "ERROR: Unabled to remove $dirToClean/$bigFile"
                    fi
            else
                echo "$bigFile is less than $fileSizeBytes bytes. Leaving in place..."
        fi
    done
}

function main () {
    checkTheDir
    convertToBytes
    cleanTheDir
}

## <-- Script --> ##

main

exit 0

# Evanesco *waves wand*
