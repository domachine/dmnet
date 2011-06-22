#!/bin/bash

. /etc/rc.conf
. /etc/rc.d/functions
. /usr/lib/network/network

# Array that will be filled with available networks
networks=()
version_string="dmnet 0.1.4"

network_is_on()
{
    declare -i i

    for (( i = 0; i < ${#networks[@]}; ++i )); do
        [[ ${networks[$i]} == $1 ]] && return 0
    done
    
    return 1
}

device_status()
{
    local carrier="/sys/class/net/$1/carrier"
    cat $carrier &>/dev/null || ifconfig "$1" up
    test $(cat $carrier) = 1
}

check_wlan()
{
    local found_wlan=1

    [[ -z $WLAN_TRIGGER ]] || echo "WLAN_TRIGGER setting was renamed to DMNET_WLAN_TRIGGER"
    [[ -z $DMNET_WLAN_TRIGGER ]] && return 1

    # Activate network-interface
    stat_busy "Checking wlan interface"
    if ! device_status "wlan0"; then
        stat_append " -- not yet connected"
        stat_done
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
        while (( i < ${#DMNET_WLAN_TRIGGER[@]} )); do
            if network_is_on "${DMNET_WLAN_TRIGGER[$i]}"; then
                profile_up "${DMNET_WLAN_TRIGGER[$(( i+1 ))]}"
                [[ $? -eq 0 ]] && {
                    found_wlan=0
                    break
                }
            fi

            (( i += 2 ))
        done
    else
        stat_done
    fi

    return $found_wlan
}

check_network()
{
    [[ $(id -u) != 0 ]] && {
        echo "dmnet: You must be root to run that script." >&2
        exit 1
    }

    check_wlan || {
        [[ -z $DMNET_ETHERNET_INTERFACE ]] || {
            stat_busy "Checking cable-connection"
            if device_status $DMNET_ETHERNET_INTERFACE; then
                stat_append " -- connection detected"
                stat_done
                dhcpcd $DMNET_ETHERNET_INTERFACE
            else
                stat_append " -- no connection"
                stat_done
            fi
        }
    }
}

case "$1" in
    start)
        check_network
        ;;
    --version|-v)
        echo "$version_string"
        ;;
    *)
        check_network
        ;;
esac

exit 0
