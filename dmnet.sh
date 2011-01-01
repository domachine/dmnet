#!/bin/bash

. /etc/rc.conf
. /etc/rc.d/functions

# Array that will be filled with available networks
networks=()
version_string="dmnet 0.1.1"

network_is_on()
{
    declare -i i

    for (( i = 0; i < ${#networks[@]}; ++i )); do
        [[ ${networks[$i]} == $1 ]] && return 0
    done
    
    return 1
}

case "$1" in
    start)
        # Activate network-interface
        stat_busy "Setting up wlan interface"
        ifconfig wlan0 up

        if [[ $? -eq 0 ]]; then
            stat_done
        else
            stat_fail
            exit 1
        fi

        stat_busy "Scanning for wireless networks"

        essids=$(iwlist wlan0 scan | \
            awk -F '(:| *)' '$2 == "ESSID" {print $3}')

        # Runtime variable
        declare -i i=0

        # Read networks
        tmp=$(mktemp)

        eval echo "'$essids'" >$tmp

        while read network; do
            # Filter networks with empty essids
            if [[ $network == \"\" ]]; then
                continue
            fi

            eval networks[$i]=$network
            (( ++i ))
        done < $tmp

        # Cleanup
        rm $tmp

        stat_done

        i=0

        # Loop through all triggers and activate them
        while (( i < ${#WLAN_TRIGGER[@]} )); do
            if network_is_on "${WLAN_TRIGGER[$i]}"; then
                netcfg "${WLAN_TRIGGER[$(( i+1 ))]}"
                [[ $? -eq 0 ]] && break
            fi

            (( i += 2 ))
        done
        ;;
    --version|-v)
        echo "$version_string"
        ;;  
esac

exit 0
