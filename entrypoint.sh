#!/bin/bash

# Apptainer-Compatible Entrypoint Script
# Based on original simple design with compatibility improvements
# K. Nemoto 13 Sep 2025
# 1.0.14: add shared folder support for Windows/macOS

# Default mode is GUI
MODE=${MODE:-gui}

# Function to detect if running in Apptainer/Singularity
is_apptainer() {
    # Check for Apptainer/Singularity environment variables
    [ -n "$APPTAINER_NAME" ] || [ -n "$SINGULARITY_NAME" ] || 
    # Check for Apptainer-specific filesystem characteristics
    [ -f /.singularity.d/Singularity ] || [ -f /.singularity.d/env/01-base.sh ] ||
    # Check if root filesystem is read-only (common in Apptainer)
    ( mount | grep -q "/ .*ro," ) ||
    # Check for specific Apptainer process patterns
    ( ps aux | grep -q "[a]pptainer\|[s]ingularity" )
}

# Function to setup VNC password if needed
setup_vnc() {
    if [ ! -d ~/.vnc ]; then
        mkdir -p ~/.vnc 2>/dev/null || true
    fi
    if [ ! -f ~/.vnc/passwd ]; then
        echo "lin4neuro" | vncpasswd -f > ~/.vnc/passwd 2>/dev/null || true
        chmod 600 ~/.vnc/passwd 2>/dev/null || true
    fi
}

# Function to setup XFCE configuration for Apptainer
setup_apptainer_config() {
    echo "Setting up XFCE configuration for Apptainer..."
    
    # Create writable config directories in /tmp
    export XDG_CONFIG_HOME=/tmp/.config
    export XDG_CACHE_HOME=/tmp/.cache
    export XDG_DATA_HOME=/tmp/.local/share
    export XDG_RUNTIME_DIR=/tmp/runtime-$(id -u)
    
    mkdir -p "$XDG_CONFIG_HOME/xfce4/xfconf/xfce-perchannel-xml"
    mkdir -p "$XDG_CONFIG_HOME/xfce4/terminal"
    mkdir -p "$XDG_CACHE_HOME"
    mkdir -p "$XDG_DATA_HOME"
    mkdir -p "$XDG_RUNTIME_DIR"
    chmod 700 "$XDG_RUNTIME_DIR"
    
    # Copy XFCE configuration files to writable location
    if [ -f /home/brain/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml ]; then
        cp /home/brain/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml "$XDG_CONFIG_HOME/xfce4/xfconf/xfce-perchannel-xml/"
    fi
    if [ -f /home/brain/.config/xfce4/terminal/terminalrc ]; then
        cp /home/brain/.config/xfce4/terminal/terminalrc "$XDG_CONFIG_HOME/xfce4/terminal/"
    fi
    
    # Create minimal xfce4-session configuration for Apptainer
    cat > "$XDG_CONFIG_HOME/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-session" version="1.0">
  <property name="startup" type="empty">
    <property name="screensaver" type="empty">
      <property name="enabled" type="bool" value="false"/>
    </property>
  </property>
  <property name="general" type="empty">
    <property name="FailsafeSessionName" type="string" value="Failsafe"/>
    <property name="SessionName" type="string" value="Default"/>
    <property name="SaveOnExit" type="bool" value="false"/>
  </property>
</channel>
EOF
}

# Function to start D-Bus session (Apptainer only)
start_dbus_apptainer() {
    echo "Starting D-Bus session for Apptainer..."
    # Kill any existing dbus session
    pkill -f "dbus-daemon.*session" 2>/dev/null || true
    
    # Start new dbus session
    export $(dbus-launch)
    echo "D-Bus session started: $DBUS_SESSION_BUS_ADDRESS"
}

# Function to start services manually (for Apptainer)
start_gui_apptainer() {
    echo "Starting GUI services manually for Apptainer..."
    echo "Access via web browser at: http://localhost:6080"
    echo "VNC password: lin4neuro"
    
    # Ensure VNC is set up
    setup_vnc
    
    # Setup XFCE config for Apptainer
    setup_apptainer_config
    
    # Start D-Bus session
    start_dbus_apptainer
    
    # Set display and minimal Qt settings
    export DISPLAY=:1
    unset SESSION_MANAGER
    
    # Start Xvfb (virtual display)
    echo "Starting virtual display..."
    /usr/bin/Xvfb :1 -screen 0 1920x1080x24 > /tmp/xvfb.log 2>&1 &
    XVFB_PID=$!
    sleep 3
    
    # Start x11vnc (VNC server)
    echo "Starting VNC server..."
    /usr/bin/x11vnc -display :1 -xkb -forever -shared -rfbauth ~/.vnc/passwd > /tmp/x11vnc.log 2>&1 &
    VNC_PID=$!
    sleep 2
    
    # Start XFCE4 desktop with D-Bus
    echo "Starting desktop environment..."
    dbus-launch --exit-with-session /usr/bin/startxfce4 > /tmp/xfce4.log 2>&1 &
    XFCE_PID=$!
    sleep 5
    
    # Start noVNC web server
    echo "Starting noVNC web server..."
    /usr/share/novnc/utils/launch.sh --vnc localhost:5900 --listen 0.0.0.0:6080 > /tmp/novnc.log 2>&1 &
    NOVNC_PID=$!
    
    # Wait a moment for services to start
    sleep 3
    
    # Check if critical services are running
    if kill -0 $XVFB_PID $VNC_PID 2>/dev/null; then
        echo ""
        echo "✓ GUI services started successfully in Apptainer!"
        echo "✓ Open web browser: http://localhost:6080"
        echo "✓ Password: lin4neuro"
        echo ""
        echo "XDG directories (Apptainer mode):"
        echo "  XDG_CONFIG_HOME: $XDG_CONFIG_HOME"
        echo "  XDG_CACHE_HOME: $XDG_CACHE_HOME"
        echo "  XDG_RUNTIME_DIR: $XDG_RUNTIME_DIR"
        echo ""
        echo "Logs: /tmp/xvfb.log, /tmp/x11vnc.log, /tmp/xfce4.log, /tmp/novnc.log"
        echo "Press Ctrl+C to stop all services"
        
        # Cleanup on exit
        cleanup() {
            echo "Stopping services..."
            kill $NOVNC_PID $XFCE_PID $VNC_PID $XVFB_PID 2>/dev/null || true
            # Kill D-Bus session
            if [ -n "$DBUS_SESSION_BUS_PID" ]; then
                kill $DBUS_SESSION_BUS_PID 2>/dev/null || true
            fi
            exit 0
        }
        trap cleanup SIGINT SIGTERM
        
        # Keep script running
        wait
    else
        echo "Error: Failed to start GUI services in Apptainer"
        echo "Check logs in /tmp/ directory"
        exit 1
    fi
}

# Function for Docker fallback (original manual startup)
start_gui_fallback() {
    echo "Starting GUI services manually (Docker fallback)..."
    echo "Access via web browser at: http://localhost:6080"
    echo "VNC password: lin4neuro"
    
    # Ensure VNC is set up
    setup_vnc
    
    # Set display and minimal Qt settings  
    export DISPLAY=:1
    unset SESSION_MANAGER
    
    # Start Xvfb (virtual display)
    echo "Starting virtual display..."
    /usr/bin/Xvfb :1 -screen 0 1920x1080x24 > /tmp/xvfb.log 2>&1 &
    XVFB_PID=$!
    sleep 3
    
    # Start x11vnc (VNC server)
    echo "Starting VNC server..."
    /usr/bin/x11vnc -display :1 -xkb -forever -shared -rfbauth ~/.vnc/passwd -cursor arrow -cursorpos > /tmp/x11vnc.log 2>&1 &
    VNC_PID=$!
    sleep 2
    
    # Start XFCE4 desktop (standard way for Docker)
    echo "Starting desktop environment..."
    /usr/bin/startxfce4 > /tmp/xfce4.log 2>&1 &
    XFCE_PID=$!
    sleep 3
    
    # Start noVNC web server
    echo "Starting noVNC web server..."
    /usr/share/novnc/utils/launch.sh --vnc localhost:5900 --listen 0.0.0.0:6080 > /tmp/novnc.log 2>&1 &
    NOVNC_PID=$!
    
    # Wait a moment for services to start
    sleep 2
    
    # Check if critical services are running
    if kill -0 $XVFB_PID $VNC_PID 2>/dev/null; then
        echo ""
        echo "✓ GUI services started successfully in Docker!"
        echo "✓ Open web browser: http://localhost:6080"
        echo "✓ Password: lin4neuro"
        echo ""
        echo "Logs: /tmp/xvfb.log, /tmp/x11vnc.log, /tmp/xfce4.log, /tmp/novnc.log"
        echo "Press Ctrl+C to stop all services"
        
        # Cleanup on exit
        cleanup() {
            echo "Stopping services..."
            kill $NOVNC_PID $XFCE_PID $VNC_PID $XVFB_PID 2>/dev/null || true
            exit 0
        }
        trap cleanup SIGINT SIGTERM
        
        # Keep script running
        wait
    else
        echo "Error: Failed to start GUI services"
        echo "Check logs in /tmp/ directory"
        exit 1
    fi
}

case "$MODE" in
    "gui")
        echo "Starting GUI mode..."
        
        # Ensure VNC password is set up
        setup_vnc
        
        # Create necessary directories in /tmp (writable in both Docker and Apptainer)
        mkdir -p /tmp/logs 2>/dev/null || true
        
        # Detect environment and choose appropriate startup method
        if is_apptainer; then
            echo "Detected Apptainer/Singularity environment"
            start_gui_apptainer
        else
            echo "Detected Docker/standard environment"
            # Try supervisord first (should work in Docker)
            if /usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf 2>/tmp/supervisord_error.log; then
                # supervisord succeeded (typical Docker case)
                echo "Started with supervisord"
            else
                # supervisord failed, fall back to manual startup for Docker
                echo "supervisord failed, falling back to manual startup..."
                echo "supervisord error log:"
                cat /tmp/supervisord_error.log 2>/dev/null || echo "No error log available"
                start_gui_fallback
            fi
        fi
        ;;
    "bash")
        echo "Starting interactive bash session..."
        # Set DISPLAY variable for X11 applications if needed
        export DISPLAY=${DISPLAY:-:1}
        exec /bin/bash -l
        ;;
    *)
        echo "Unknown mode: $MODE"
        echo "Available modes: gui, bash"
        echo ""
        echo "Usage:"
        echo "  Docker:     docker run -e MODE=gui kytk/abis-2026"
        echo "  Apptainer:  apptainer run --env MODE=gui abis-2026.sif"
        echo "  Default:    gui mode (if no mode specified)"
        echo ""
        echo "Examples:"
        echo "  GUI mode:   docker run kytk/abis-2026"
        echo "             apptainer run abis-2026.sif"
        echo "  Shell:      docker run -it -e MODE=bash kytk/abis-2026"
        echo "             apptainer run --env MODE=bash abis-2026.sif"
        exit 1
        ;;
esac
