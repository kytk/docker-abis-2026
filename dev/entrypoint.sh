#!/bin/bash

# Apptainer-Compatible Entrypoint Script
# Based on original simple design with compatibility improvements
# K. Nemoto 20 Aug 2025

# Default mode is GUI
MODE=${CONTAINER_MODE:-gui}

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

# Function to start services manually (fallback for Apptainer)
start_gui_manual() {
    echo "Starting GUI services manually..."
    echo "Access via web browser at: http://localhost:6080"
    echo "VNC password: lin4neuro"
    
    # Ensure VNC is set up
    setup_vnc
    
    # Set display
    export DISPLAY=:1
    
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
    
    # Start XFCE4 desktop
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
        echo "✓ GUI services started successfully!"
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
        
        # Try supervisord first (should work in Docker and compatible Apptainer setups)
        if /usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf 2>/dev/null; then
            # supervisord succeeded (typical Docker case)
            echo "Started with supervisord"
        else
            # supervisord failed (typical Apptainer case with read-only filesystem)
            echo "supervisord failed, falling back to manual startup..."
            start_gui_manual
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
        echo "  Docker:     docker run -e CONTAINER_MODE=gui kytk/abis-2026"
        echo "  Apptainer:  apptainer run --env CONTAINER_MODE=gui abis-2026.sif"
        echo "  Default:    gui mode (if no mode specified)"
        echo ""
        echo "Examples:"
        echo "  GUI mode:   docker run kytk/abis-2026"
        echo "             apptainer run abis-2026.sif"
        echo "  Shell:      docker run -e CONTAINER_MODE=bash kytk/abis-2026"
        echo "             apptainer run --env CONTAINER_MODE=bash abis-2026.sif"
        exit 1
        ;;
esac
