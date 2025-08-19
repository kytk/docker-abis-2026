#!/bin/bash

# Default mode is GUI
MODE=${CONTAINER_MODE:-gui}

case "$MODE" in
    "gui")
        echo "Starting GUI mode..."
        exec /usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf
        ;;
    "bash")
        echo "Starting interactive bash session..."
        # Set DISPLAY variable for X11 applications if needed
        export DISPLAY=:1
        exec /bin/bash -l
        ;;
    *)
        echo "Unknown mode: $MODE"
        echo "Available modes: gui, bash"
        exit 1
        ;;
esac