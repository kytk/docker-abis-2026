## Dockerfile to make "docker-abis-2026" (Optimized)
## This file makes a container image of docker-abis-2026
## K. Nemoto 19 Aug 2025

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Tokyo

##### Part 1. Base of Container #####
# Core system and X11
RUN set -ex && \
    apt-get update && \
    apt-get install -y \
      xfce4 \
      xfce4-terminal \
      xfce4-indicator-plugin  \
      xfce4-clipman \
      xfce4-clipman-plugin \
      xfce4-statusnotifier-plugin  \
      xfce4-screenshooter \
      shimmer-themes \
      xinit \
      build-essential  \
      dkms \
      thunar-archive-plugin \
      file-roller \
      xdg-utils \ 
      tightvncserver \
      novnc \
      websockify \
      net-tools \
      supervisor \
      x11vnc \
      xvfb \
      dbus-x11 \
      sudo \
      gnupg \
      python3-pip \
      python3-venv \
      python3-dev \
      python3-tk \
      python3-gpg \
      tzdata \
      less \
      iputils-ping \
      nano \
      rsync \
      locate \
      git \
      apt-utils \
      at-spi2-core \
      bc \
      curl \
      wget \
      dc \
      default-jre \
      evince \
      gedit \
      gnome-system-monitor \
      gnome-system-tools \
      baobab \
      imagemagick \
      rename \
      ntp \
      tree \
      unzip \
      vim  \
      zip \
      tcsh \
      apturl \
      dmz-cursor-theme \
      p7zip-full \
      gnupg \
      meld \
      software-properties-common \
      fonts-noto \
      fonts-noto-cjk \
      pigz \
      appmenu-gtk-module-common \
      appmenu-gtk2-module \
      libappmenu-gtk2-parser0 \
      libreoffice-calc \
      libreoffice-writer \
      octave \
      gawk \
      sed \
      libopenblas-base \
      libjpeg62 \
      libgtk2.0-0 \
      language-pack-en \
      libx11-dev \
      gettext \
      xterm \
      x11-apps \
      csh \
      file \
      xorg \
      xorg-dev \
      xserver-xorg-dev \
      libncurses5 && \
    # Timezone setup
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata && \
    # Python setup
    python3 -m pip install --upgrade pip && \
    pip install --no-cache-dir numpy pandas pydicom gdcm \
       heudiconv nipype nibabel jupyter notebook \
       bash_kernel octave_kernel && \
    python3 -m bash_kernel.install && \
    # Firefox setup
    install -d -m 0755 /etc/apt/keyrings && \
    wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | \
      gpg --dearmor -o /etc/apt/keyrings/packages.mozilla.org.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.gpg] https://packages.mozilla.org/apt mozilla main" | tee /etc/apt/sources.list.d/mozilla.list > /dev/null && \
    echo 'Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000'|\
      tee /etc/apt/preferences.d/mozilla && \
    apt-get update && \
    apt-get install -y firefox && \
    xdg-mime default firefox.desktop text/html && \
    # Cleanup apt caches
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Desktop background and bash aliases
COPY deep_ocean.png /usr/share/backgrounds/
COPY bash_aliases /etc/skel/.bash_aliases
COPY bash_aliases /root/.bash_aliases
RUN rm /usr/share/backgrounds/xfce/xfce*.*p*g && \
    chmod 644 /root/.bash_aliases && \
    chmod 644 /etc/skel/.bash_aliases

##### Part 2. noVNC and User Setup #####
RUN set -ex && \
    # noVNC scaling setting
    sed -i "s/UI.initSetting('resize', 'off');/UI.initSetting('resize', 'local');/g" /usr/share/novnc/app/ui.js && \
    # Create user
    useradd -m -s /bin/bash brain && \
    echo "brain:lin4neuro" | chpasswd && \
    adduser brain sudo && \
    # VNC setup
    mkdir -p /home/brain/.vnc && \
    echo "lin4neuro" | vncpasswd -f > /home/brain/.vnc/passwd && \
    chmod 600 /home/brain/.vnc/passwd && \
    chown -R brain:brain /home/brain/.vnc

##### Part 3. Neuroimaging Software (統合インストール) #####
# Copy all packages at once
COPY packages/* /tmp/

# Install all neuroimaging software in a single layer
RUN set -ex && \
    cd /tmp/ && \
    # Mango
    unzip mango_unix.zip -d /usr/local/ && \
    rm -f mango_unix.zip && \
    # MRIcroGL
    unzip MRIcroGL_linux.zip -d /usr/local/ && \
    rm -f MRIcroGL_linux.zip && \
    # dcm2niix
    mkdir -p /usr/local/dcm2niix && \
    unzip dcm2niix_lnx.zip -d /usr/local/dcm2niix && \
    rm -f dcm2niix_lnx.zip && \
    # MRtrix3
    unzip mrtrix3_jammy.zip -d /usr/local && \
    rm -f mrtrix3_jammy.zip && \
    # ANTs
    unzip ANTs-jammy.zip -d /usr/local && \
    rm -f ANTs-jammy.zip && \
    # AlizaMS
    dpkg -i ./alizams_1.9.10+git0.95d7909-1+1.1_amd64.deb || true && \
    apt-get update && apt-get install -f -y && \
    rm -f alizams_1.9.10+git0.95d7909-1+1.1_amd64.deb && \
    # Matlab MCR R2024b
    mkdir -p mcr_r2024b && \
    mv MATLAB_Runtime_R2024b_Update_1_glnxa64.zip mcr_r2024b/ && \
    cd mcr_r2024b && \
    unzip MATLAB_Runtime_R2024b_Update_1_glnxa64.zip && \
    ./install -mode silent -agreeToLicense yes -destinationFolder /usr/local/MATLAB/MCR/ && \
    cd /tmp/ && \
    rm -rf mcr_r2024b && \
    # SPM25
    unzip spm_standalone_25.01.02_Linux.zip && \
    mv spm_standalone spm25_standalone && \
    mv spm25_standalone /usr/local && \
    chown -R brain:brain /usr/local/spm25_standalone && \
    rm -f spm_standalone_25.01.02_Linux.zip && \
    # CONNv2407
    unzip conn22v2407_standalone_jammy_R2024b.zip -d /usr/local && \
    chown -R brain:brain /usr/local/conn22v2407_standalone && \
    chmod 755 /usr/local/conn22v2407_standalone/run_conn.sh && \
    chmod 755 /usr/local/conn22v2407_standalone/conn && \
    rm -f conn22v2407_standalone_jammy_R2024b.zip && \
    # FSL
    tar -xf fsl-6.0.7.18-jammy.tar.gz -C /usr/local/ && \
    rm -f fsl-6.0.7.18-jammy.tar.gz && \
    # FreeSurfer 8.1.0
    dpkg -i ./freesurfer_ubuntu22-8.1.0_amd64.deb || true && \
    apt-get update && apt-get install -f -y && \
    dpkg --configure -a && \
    mkdir -p /home/brain/freesurfer/8.1.0 && \
    cp -rs /usr/local/freesurfer/8.1.0/subjects /home/brain/freesurfer/8.1.0/ && \
    rm -f freesurfer_ubuntu22-8.1.0_amd64.deb && \
    # Scripts
    mkdir -p /home/brain/git && \
    cd /home/brain/git && \
    git clone https://gitlab.com/kytk/fs-scripts.git && \
    git clone https://gitlab.com/kytk/kn-scripts.git && \
    chown -R brain:brain /home/brain/git && \
    # Final cleanup
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* && \
    rm -rf /tmp/* /var/tmp/* && \
    # Remove unnecessary files from installed software
    find /usr/local -name "*.o" -delete && \
    find /usr/local -name "*.a" -delete && \
    find /usr/local -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true

##### MATLAB Cleanup #####
# Stage 1: Ultra-safe MATLAB MCR optimization (100% safe, no impact on SPM/CONN)

RUN set -ex && \
    cd /usr/local/MATLAB/MCR/R2024b && \
    \
    # 1. Remove documentation files that can be safely deleted
    rm -f matlabruntime_license_agreement.pdf \
          patents.txt \
          trademarks.txt 2>/dev/null || true && \
    \
    # 2. Remove help directory (SPM/CONN do not use this)
    rm -rf help/ 2>/dev/null || true && \
    \
    # 3. Find and remove documentation-related directories
    find . -name "*doc*" -type d -exec rm -rf {} + 2>/dev/null || true && \
    find . -name "*example*" -type d -exec rm -rf {} + 2>/dev/null || true && \
    find . -name "*demo*" -type d -exec rm -rf {} + 2>/dev/null || true && \
    find . -name "*tutorial*" -type d -exec rm -rf {} + 2>/dev/null || true && \
    \
    # 4. Remove PDF and HTML files
    find . -name "*.pdf" -delete 2>/dev/null || true && \
    find . -name "*.html" -delete 2>/dev/null || true && \
    find . -name "*.htm" -delete 2>/dev/null || true && \
    \
    # 5. Remove files for other platforms (non-Linux)
    find . -name "*win32*" -delete 2>/dev/null || true && \
    find . -name "*win64*" -delete 2>/dev/null || true && \
    find . -name "*maci*" -delete 2>/dev/null || true && \
    find . -name "*Darwin*" -delete 2>/dev/null || true && \
    find . -name "*.exe" -delete 2>/dev/null || true && \
    find . -name "*.dll" -delete 2>/dev/null || true && \
    find . -name "*.dylib" -delete 2>/dev/null || true && \
    \
    # 6. Remove development-related files (headers, source code)
    find . -name "*.h" -delete 2>/dev/null || true && \
    find . -name "*.hpp" -delete 2>/dev/null || true && \
    find . -name "*.c" -delete 2>/dev/null || true && \
    find . -name "*.cpp" -delete 2>/dev/null || true && \
    find . -name "*.m~" -delete 2>/dev/null || true && \
    find . -name "*.bak" -delete 2>/dev/null || true && \
    \
    # 7. Remove temporary files
    find . -name "*.log" -delete 2>/dev/null || true && \
    find . -name "*.tmp" -delete 2>/dev/null || true && \
    find . -name ".DS_Store" -delete 2>/dev/null || true && \
    find . -name "Thumbs.db" -delete 2>/dev/null || true

# Check size after optimization
RUN echo "=== MATLAB size after Stage 1 optimization ===" && \
    du -sh /usr/local/MATLAB 2>/dev/null || echo "Checking size..." && \
    echo "=== Verify deleted files ===" && \
    echo "PDF files:" && find /usr/local/MATLAB/MCR/R2024b -name "*.pdf" | wc -l && \
    echo "Help directory exists:" && ls /usr/local/MATLAB/MCR/R2024b/help/ 2>/dev/null | wc -l || echo "0 (deleted)"

# Stage 2: MATLAB Toolbox optimization (Remove unused toolboxes, keep SPM/CONN essentials)
# This stage removes toolboxes that are not required by SPM25 and CONN

RUN set -ex && \
    cd /usr/local/MATLAB/MCR/R2024b/toolbox && \
    \
    # === Keep these essential toolboxes for SPM/CONN ===
    # matlab - Core MATLAB functionality
    # stats - Statistical functions (required by SPM/CONN)
    # signal - Signal processing (required by SPM/CONN) 
    # images - Image processing (required by SPM/CONN)
    # shared - Shared libraries (essential)
    # compiler - Compiler libraries (essential for standalone apps)
    # matlabcoder - May be required for compiled applications
    \
    # === Remove specialized toolboxes not used by SPM/CONN ===
    \
    # 1. Remove Simulink-related toolboxes (Large, not used by SPM/CONN)
    rm -rf simulink* \
           stateflow* \
           sldv* \
           slvnv* \
           sl3d* \
           slrt* \
           sldo* \
           rtw* \
           simscape* \
           simevents* \
           simpowersys* \
           simrf* \
           simbio* 2>/dev/null || true && \
    \
    # 2. Remove automotive/transportation toolboxes
    rm -rf automotive* \
           driving* \
           vehicle* \
           uav* \
           lidar* \
           radar* 2>/dev/null || true && \
    \
    # 3. Remove aerospace toolboxes  
    rm -rf aerospace* \
           satellite* \
           antenna* \
           phased* 2>/dev/null || true && \
    \
    # 4. Remove financial/economic toolboxes
    rm -rf finance* \
           econ* \
           risk* \
           trading* 2>/dev/null || true && \
    \
    # 5. Remove robotics/control toolboxes (SPM/CONN don't use these)
    rm -rf robotics* \
           nav* \
           control* \
           robust* \
           fuzzy* \
           slcontrol* 2>/dev/null || true && \
    \
    # 6. Remove specialized engineering toolboxes
    rm -rf rf* \
           mixed* \
           serdes* \
           antenna* \
           eda* \
           hdlcoder* \
           hdlverifier* \
           fixedpoint* \
           vision* \
           audio* \
           dsp* \
           comm* \
           wireless* 2>/dev/null || true && \
    \
    # 7. Remove AI/Machine Learning toolboxes (SPM has its own implementations)
    rm -rf nnet* \
           deeplearning* \
           reinforcementlearning* \
           textanalytics* \
           predmaint* \
           gads* \
           optim* \
           globaloptim* 2>/dev/null || true && \
    \
    # 8. Remove bioinformatics toolboxes (different from neuroimaging)
    rm -rf bioinfo* \
           biograph* 2>/dev/null || true && \
    \
    # 9. Remove coder toolboxes that may not be needed
    rm -rf coder* \
           gpucoder* \
           polyspacecodeprover* \
           polyspacebugfinder* 2>/dev/null || true && \
    \
    # 10. Remove testing/verification toolboxes
    rm -rf matlab*test* \
           sltest* \
           coverage* \
           requirements* 2>/dev/null || true && \
    \
    # 11. Remove parallel computing (if not needed by SPM/CONN)
    rm -rf parallel* \
           distributed* 2>/dev/null || true && \
    \
    # 12. Remove GUI development toolboxes
    rm -rf appdesigner* \
           uicomponents* 2>/dev/null || true && \
    \
    # 13. Clean up any remaining specialized toolboxes
    rm -rf instrument* \
           daq* \
           imaq* \
           opc* \
           database* \
           datafeed* \
           trading* \
           spreadsheet* 2>/dev/null || true

# Verify remaining essential toolboxes
RUN echo "=== Remaining essential toolboxes for SPM/CONN ===" && \
    ls -la /usr/local/MATLAB/MCR/R2024b/toolbox/ | grep -E "(matlab|stats|signal|images|shared|compiler)" || \
    echo "Listing all remaining toolboxes:" && \
    ls /usr/local/MATLAB/MCR/R2024b/toolbox/

# Check size after toolbox optimization  
RUN echo "=== MATLAB size after Stage 2 (toolbox) optimization ===" && \
    du -sh /usr/local/MATLAB && \
    echo "=== Toolbox directory size ===" && \
    du -sh /usr/local/MATLAB/MCR/R2024b/toolbox/




##### Part 4. User Configuration #####
RUN set -ex && \
    mkdir -p /home/brain/logs && \
    mkdir -p /home/brain/.config/xfce4/xfconf/xfce-perchannel-xml && \
    mkdir -p /home/brain/.config/xfce4/terminal && \
    chown -R brain:brain /home/brain/.config && \
    chown -R brain:brain /home/brain/logs && \
    echo '\n# Disable screensaver\nxset s off' >> /home/brain/.bashrc

# Copy configuration files
COPY xfce4-desktop.xml /home/brain/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
COPY terminalrc /home/brain/.config/xfce4/terminal/terminalrc
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN chown brain:brain /home/brain/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml && \
    chown brain:brain /home/brain/.config/xfce4/terminal/terminalrc

ENV DISPLAY=:1

EXPOSE 6080

USER brain
ENV USER=brain

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
