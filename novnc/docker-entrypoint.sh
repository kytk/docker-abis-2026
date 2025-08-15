#!/bin/bash

# Use default value if resolution is not specified
RESOLUTION=${RESOLUTION:-1600x900x24}

# Update the resolution in supervisord.conf file
sed -i "s|%(ENV_RESOLUTION)s|$RESOLUTION|g" /etc/supervisor/conf.d/supervisord.conf

# Execute supervisord
exec /usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf

