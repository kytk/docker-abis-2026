#!/bin/bash

WALLPAPER="/usr/share/backgrounds/xfce/deep_ocean.png"

# acquire settings
CONFIG_LIST=$(xfconf-query -c xfce4-desktop -l)

# acquire monitor info
MONITORS=$(echo "$CONFIG_LIST" | \
    grep "workspace[0-9]/last-image" | \
    sed -e 's|/backdrop/screen0/||' -e 's|/workspace[0-9]/last-image||' | \
    sort -u)

# set wallpaper for each monitor
echo "$MONITORS" | while read monitor; do
    # get number of workspaces for the monitor
    WORKSPACES=$(echo "$CONFIG_LIST" | \
        grep "/backdrop/screen0/${monitor}/workspace[0-9]/last-image" | \
        sed -e "s|.*/workspace||" -e "s|/last-image||" | \
        sort -n)

    # apply settings to each workspace
    echo "$WORKSPACES" | while read workspace; do
        xfconf-query -c xfce4-desktop \
            -p "/backdrop/screen0/${monitor}/workspace${workspace}/last-image" \
            -s "$WALLPAPER"
        xfconf-query -c xfce4-desktop \
            -p "/backdrop/screen0/${monitor}/workspace${workspace}/image-style" \
            -s 5
        xfconf-query -c xfce4-desktop \
            -p "/backdrop/screen0/${monitor}/workspace${workspace}/color-style" \
            -s 0
    done
done
