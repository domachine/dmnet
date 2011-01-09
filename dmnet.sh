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

device_status()
{
    CARRIER="/sys/class/net/$1/carrier"
    cat $CARRIER &>/dev/null || ifconfig "$1" up
    test $(cat $CARRIER) = 1
}


case "$1" in
    start)
        found_wlan=0
        
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

            found_wlan=0
            # Loop through all triggers and activate them
            while (( i < ${#WLAN_TRIGGER[@]} )); do
                if network_is_on "${WLAN_TRIGGER[$i]}"; then
                    netcfg "${WLAN_TRIGGER[$(( i+1 ))]}"
                    [[ $? -eq 0 ]] && {
                        found_wlan=1
                        break
                    }
                fi

                (( i += 2 ))
            done
        else
            stat_done
        fi

        if [[ -f /etc/network.d/ethernet-dhcp ]] && ((found_wlan == 0)); then
            stat_busy "Checking ethernet-connection"

            if device_status "eth0"; then
                stat_append " -- connection detected"
                stat_done
                netcfg ethernet-dhcp
            else
                stat_append " -- no connection"
                stat_done
            fi
        fi
        ;;
    --version|-v)
        echo "$version_string"
        ;;
esac

exit 0
