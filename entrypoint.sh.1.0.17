#!/bin/bash
# Entrypoint script for ABIS container
# Handles both interactive and non-interactive modes
# 1.0.17

set -e

echo "=== Starting entrypoint.sh ==="
echo "User: $(whoami)"
echo "Home: $HOME"
echo "Display: $DISPLAY"

# Initialize environment
export HOME=/home/brain
export USER=brain
export DISPLAY=:1

# Create necessary directories
mkdir -p /home/brain/.vnc
mkdir -p /home/brain/logs
mkdir -p /home/brain/.cache
mkdir -p /home/brain/.config

# Set up VNC password if not exists
if [ ! -f /home/brain/.vnc/passwd ]; then
    echo "Setting up VNC password..."
    echo "lin4neuro" | vncpasswd -f > /home/brain/.vnc/passwd
    chmod 600 /home/brain/.vnc/passwd
fi

# Source environment setup
if [ -f /home/brain/.bashrc ]; then
    source /home/brain/.bashrc
fi

# Check if running interactively (when using docker run -it)
if [ -t 0 ] && [ -t 1 ]; then
    echo "=== Interactive mode detected ==="
    echo "Starting bash shell..."
    cd /home/brain
    exec /bin/bash
else
    echo "=== Non-interactive mode (daemon) ==="
    echo "Starting supervisord for VNC services..."
    
    # Check if supervisord config exists
    if [ ! -f /etc/supervisor/conf.d/supervisord.conf ]; then
        echo "ERROR: supervisord.conf not found!"
        echo "Creating basic supervisord config..."
        
        cat > /etc/supervisor/conf.d/supervisord.conf << 'EOF'
[supervisord]
nodaemon=true
user=root
logfile=/home/brain/logs/supervisord.log
pidfile=/home/brain/logs/supervisord.pid
childlogdir=/home/brain/logs

[program:xvfb]
command=/usr/bin/Xvfb :1 -screen 0 1024x768x24 -ac +extension GLX +render -noreset
user=brain
autorestart=true
stdout_logfile=/home/brain/logs/xvfb.log
stderr_logfile=/home/brain/logs/xvfb.log

[program:xfce4]
command=/usr/bin/startxfce4
user=brain
environment=DISPLAY=":1",HOME="/home/brain",USER="brain"
autorestart=true
stdout_logfile=/home/brain/logs/xfce4.log
stderr_logfile=/home/brain/logs/xfce4.log

[program:x11vnc]
command=/usr/bin/x11vnc -display :1 -nopw -listen localhost -xkb -ncache 10 -ncache_cr -forever
user=brain
autorestart=true
stdout_logfile=/home/brain/logs/x11vnc.log
stderr_logfile=/home/brain/logs/x11vnc.log

[program:novnc]
command=/usr/share/novnc/utils/novnc_proxy --vnc localhost:5900 --listen 6080
user=brain
autorestart=true
stdout_logfile=/home/brain/logs/novnc.log
stderr_logfile=/home/brain/logs/novnc.log
EOF
    fi
    
    # Make sure log directory exists and has correct ownership
    mkdir -p /home/brain/logs
    chown -R brain:brain /home/brain/logs
    
    echo "Starting supervisord..."
    exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
fi
