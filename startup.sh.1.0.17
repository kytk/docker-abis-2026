#!/bin/bash
# Shared Folder Setup - Windows/macOS/Linux Cross-platform Support
# Author: K. Nemoto
# Version: 1.0.17

echo "=== Setting up shared folder ==="
echo "Current user: $(whoami)"

echo "=== Checking directories ==="
echo "Checking /root/share..."
if [[ -d /root/share ]]; then
    echo "  /root/share EXISTS"
    root_share_files=$(ls -A /root/share 2>/dev/null | wc -l)
    echo "  Files in /root/share: $root_share_files"
else
    echo "  /root/share does NOT exist"
    root_share_files=0
fi

echo "Checking /home/brain/share..."
if [[ -e /home/brain/share ]]; then
    echo "  /home/brain/share EXISTS"
    if [[ -d /home/brain/share ]]; then
        brain_share_files=$(ls -A /home/brain/share 2>/dev/null | wc -l)
        echo "  Files in /home/brain/share: $brain_share_files"
    else
        brain_share_files=0
        echo "  /home/brain/share is not a directory"
    fi
else
    echo "  /home/brain/share does NOT exist"
    brain_share_files=0
fi

echo "=== Environment detection and setup ==="

# Windows: /root/share has content, need to bind mount to /home/brain/share
if [[ -d /root/share ]] && [[ $root_share_files -gt 0 ]] && [[ $brain_share_files -eq 0 ]]; then
    echo "DETECTED: Windows environment"
    
    # Remove any existing empty directory
    rm -rf /home/brain/share 2>/dev/null
    
    # Create mount point
    mkdir -p /home/brain/share
    
    # Change ownership of source directory
    echo "Setting ownership of /root/share..."
    chown -R brain:brain /root/share
    
    # Create bind mount
    echo "Creating bind mount..."
    if mount --bind /root/share /home/brain/share; then
        # Ensure mount point has correct ownership
        chown brain:brain /home/brain/share
        echo "SUCCESS: Windows setup complete"
        echo "Shared folder available at: /home/brain/share"
    else
        echo "ERROR: Bind mount failed!"
        echo "Shared folder available at: /root/share"
        exit 1
    fi
    
# macOS: /home/brain/share already mounted with external drive
elif [[ -d /home/brain/share ]] && [[ $brain_share_files -gt 0 ]]; then
    echo "DETECTED: macOS/Linux environment"
    echo "External drive already mounted to /home/brain/share"
    
    # Ensure correct ownership
    chown -R brain:brain /home/brain/share 2>/dev/null || true
    echo "SUCCESS: macOS/Linux setup complete"
    echo "Shared folder available at: /home/brain/share"
    
# Force Windows setup if /root/share has content (fallback)
elif [[ -d /root/share ]] && [[ $root_share_files -gt 0 ]]; then
    echo "DETECTED: Force Windows setup (fallback)"
    
    # Remove existing directory and recreate
    rm -rf /home/brain/share 2>/dev/null
    mkdir -p /home/brain/share
    
    # Setup bind mount
    chown -R brain:brain /root/share
    if mount --bind /root/share /home/brain/share; then
        chown brain:brain /home/brain/share
        echo "SUCCESS: Fallback Windows setup complete"
        echo "Shared folder available at: /home/brain/share"
    else
        echo "ERROR: Fallback bind mount also failed!"
        exit 1
    fi
    
else
    echo "DETECTED: No shared folder"
    echo "INFO: Container running without shared folder"
fi

echo "=== Final verification ==="
if [[ -d /home/brain/share ]]; then
    echo "Shared folder is ready: /home/brain/share"
    echo "Contents: $(ls -la /home/brain/share 2>/dev/null | wc -l) items"
else
    echo "INFO: No shared folder configured"
fi

echo "=== Starting container ==="
exec su - brain -c "/usr/local/bin/entrypoint.sh"
