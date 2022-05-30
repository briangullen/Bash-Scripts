#!/bin/bash

# Name: network_reorder.sh
# Creator: Brian Gullen for Rocket Central 2021-11-24
# Descirption: Script to set Wi-Fi or Ethernet as primary connection based on input

source /etc/hyperfunctional || { exit 1; }

## -- Variables --##
mode="$4"
checkTopService=$( networksetup -listnetworkserviceorder | grep "(1)" | cut -d')' -f2 | xargs )
isWiFiEnabled=$(ifconfig en0 | awk '/status:/{print $2}')
dmgFolder="/Library/dmg"
receiptName=".userUpdatedNetworkOrder"
receiptPath="$dmgFolder/$receiptName"
wifiElevated="User elevated Wi-Fi"
ethernetElevated="User elevated Ethernet"

## -- FUNCTIONS -- ##

#Create receipt if needed
function createReceipt () {
if [[ ! -e "$receiptPath" ]]
    then
        hyperLogger $logTag "Receipt file not found. Creating "$receiptPath" and writing receipt."
        touch "$receiptPath"
    else
        hyperLogger $logTag "Receipt file already exists. Moving on."
fi
}

#Check if Wi-Fi is enabled. Turn it on if not.
function enableTheWifi () {
if [[ $isWiFiEnabled == "active" ]]
    then
        echo "Wifi is alread enabled. Moving on."
    else
        echo "Wifi is not enabled. Turning on WiFi before proceeding."
        networksetup -setairportpower en0 on
        sleep 5
fi
}

# Check if this needs to run. If yes, get the network services.
function elevateTheWifi () {
if [[ "$checkTopService" == "Wi-Fi" ]]
    then
        echo "Wifi is already set to first in service order. We don't need to run this."
        exit 0
    else
        echo "Wifi is not first. Gathering and ordering all network services."
        serviceList=()
        while read service; do
            echo "Found network service $service"
            serviceList+=("$service")
        done < <( networksetup -listnetworkserviceorder | grep -v "Wi-Fi" | cut -d')' -f2 | sed '/^$/d' | sed '1d' | sed 's|^[[:blank:]]*||g' )
        echo "Final Service Order: Wi-Fi ${serviceList[*]}"
        networksetup -ordernetworkservices Wi-Fi "${serviceList[@]}"
        if echo $wifiElevated >> $receiptPath
            then 
                echo "Added $wifiElevated to $receiptPath"
            else
                echo "Unable to update receipt."
        fi
fi
}

#Confirm wifi is #1
function checkTheWifi () {
checkTheServices=$( networksetup -listnetworkserviceorder | grep "(1)" | cut -d')' -f2 | xargs )
if [[ "$checkTheServices" == "Wi-Fi" ]]
    then
        hyperLogger $logTag "Wifi is now atop the service order."
    else
        hyperLogger $logTag "Something went wrong. Wifi is NOT atop the service order."
        exit 1
fi
}

#Check if there's a wired interface at top. If not move wired to the top. 
function elevateTheEthernet () {
if [[ "$checkTopService" =~ .*Ethernet.* ]] || [[ "$checkTopService" =~ .*Thunderbolt.* ]] || [[ "$checkTopService" =~ .*LAN.* ]]
    then
        echo "A Wired interface is already atop the service order. We don't need to continue."
        exit 0
    else
        echo "A wired interface is not atop the service order. Let's fix that."
        prioritizedServices=()
        deprioritizedServices=()
        unprioritizedServices=()
        while read networkService; do
            echo "Found network service $networkService"
            if [[ ${networkService} =~ .*Ethernet.* ]] || [[ ${networkService} =~ .*Thunderbolt.* ]]|| [[ ${networkService} =~ .*LAN.* ]]
                then
                    prioritizedServices+=( "${networkService}" )
            elif [[ ${networkService} =~ .*Bluetooth.* ]] || [[ ${networkService} =~ .*FireWire.* ]]|| [[ ${networkService} =~ .*Wi-Fi.* ]]
                then
                    deprioritizedServices+=( "${networkService}" )
            else 
                unprioritizedServices+=( "${networkService}" )
            fi
        done < <( networksetup -listnetworkserviceorder | cut -d')' -f2 | sed '/^$/d' | sed '1d' | sed 's|^[[:blank:]]*||g' )
        finalServiceOrder=("${prioritizedServices[@]}" "${deprioritizedServices[@]}" "${unprioritizedServices[@]}")
        echo "Final Service Order: ${finalServiceOrder[*]}"
        networksetup -ordernetworkservices "${prioritizedServices[@]}" "${deprioritizedServices[@]}" "${unprioritizedServices[@]}"
        if echo $ethernetElevated >> $receiptPath
            then
                echo "Added $ethernetElevated to $receiptPath"
            else
                echo "Unable to update receipt."
        fi
fi
}

#Confirm a wired network is #1
function checkTheEthernet () {
checkTheServices=$( networksetup -listnetworkserviceorder | grep "(1)" | cut -d')' -f2 | xargs )
if [[ "$checkTheServices" =~ .*Ethernet.* ]] || [[ "$checkTheServices" =~ .*Thunderbolt.* ]] || [[ "$checkTheServices" =~ .*LAN.* ]]
    then
        echo "A wired interface is now atop the network service order."
    else
        echo "Something went wrong. A wired interface is not atop the network service order."
        exit 1
fi
}

function checkMode() {
case "$mode" in
wifi)
echo "Running in wifi mode"
    enableTheWifi
    elevateTheWifi
    checkTheWifi
;;
ethernet)
echo "Running in ethernet mode"
    elevateTheEthernet
    checkTheEthernet
;;
*)
echo "Invalid mode"
exit 1
;;
esac
}

function main () {
    createReceipt
    checkMode
}

## -- SCRIPT -- ##

main

exit 0
