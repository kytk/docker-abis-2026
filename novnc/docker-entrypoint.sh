#!/bin/bash

# Use default value if resolution is not specified
RESOLUTION=${RESOLUTION:-1600x900x24}

# Update the resolution in supervisord.conf file
sed -i "s|%(ENV_RESOLUTION)s|$RESOLUTION|g" /etc/supervisor/conf.d/supervisord.conf

# Ensure proper permissions and directories for brain user
mkdir -p /home/brain/.config/xfce4
mkdir -p /home/brain/.cache/sessions
mkdir -p /home/brain/.local/share/xfce4
chown -R brain:brain /home/brain/.config
chown -R brain:brain /home/brain/.cache
chown -R brain:brain /home/brain/.local

# Set environment variables for X11
export DISPLAY=:1
export HOME=/home/brain

# Execute supervisord
exec /usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf
