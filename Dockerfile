# syntax=docker/dockerfile:1

# Dockerfile for kytk/abis-2026 with Multi-Stage Build
# Author: K. Nemoto
# Date: 18 Dec 2025
# Description: This Dockerfile uses a multi-stage build to create a smaller,
#              optimized container image for neuroimaging analysis.

# 1.0.18: breakdown layer

#------------------------------------------------------------------------------
# Stage 1: The "Builder" Stage
# - Installs all build-time dependencies.
# - Downloads, extracts, and installs all neuroimaging software.
# - This stage will be large, but it is discarded after the build.
#------------------------------------------------------------------------------
FROM ubuntu:22.04 AS builder

# Set non-interactive frontend for package installation
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Tokyo

# Install build-time dependencies and essential tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential ca-certificates dkms \
      curl wget git gnupg \
      unzip zip p7zip-full pigz file 

# Copy packaged software into the builder stage
#COPY packages/* /tmp/

# Install all neuroimaging software
RUN --mount=type=bind,source=packages,target=/tmp/packages \
    set -ex && \
    # MRIcroGL
    unzip /tmp/packages/MRIcroGL_linux.zip -d /usr/local/ && \
    # dcm2niix
    mkdir -p /usr/local/dcm2niix && \
    unzip /tmp/packages/dcm2niix_lnx.zip -d /usr/local/dcm2niix && \
    # MRtrix3
    unzip /tmp/packages/mrtrix3_jammy.zip -d /usr/local && \
    # ANTs
    unzip /tmp/packages/ANTs-jammy.zip -d /usr/local

RUN --mount=type=bind,source=packages,target=/tmp/packages \
    set -ex && \
    # FreeSurfer (install deps first)
    apt install -y /tmp/packages/freesurfer_ubuntu22-8.1.0_amd64.deb && \
    # MCR
    unzip /tmp/packages/MCRv97.zip -d /usr/local/freesurfer/8.1.0/ && \
    # Prepare FreeSurfer subjects directory for the user
    mkdir -p /home/brain/freesurfer/8.1.0 && \
    mkdir -p /home/brain/matlab && \
    ln -s /usr/local/freesurfer/8.1.0/subjects /home/brain/freesurfer/8.1.0/ && \
    unzip /tmp/packages/bert.zip -d /usr/local/freesurfer/8.1.0/subjects/

RUN --mount=type=bind,source=packages,target=/tmp/packages \
    set -ex && \
    # Matlab MCR R2024b
    mkdir -p /tmp/mcr_r2024b && \
    cp /tmp/packages/MATLAB_Runtime_R2024b_Update_1_glnxa64.zip /tmp/mcr_r2024b/ && \
    cd /tmp/mcr_r2024b && \
    unzip MATLAB_Runtime_R2024b_Update_1_glnxa64.zip && \
    ./install -mode silent -agreeToLicense yes -destinationFolder /usr/local/MATLAB/MCR/ && \
    rm -rf /tmp/mcr_r2024b && \
    # SPM25
    unzip /tmp/packages/spm_standalone_25.01.02_Linux.zip -d /tmp/ && \
    mv /tmp/spm_standalone /tmp/spm25_standalone && \
    mv /tmp/spm25_standalone /usr/local && \
    # CONNv2407
    unzip /tmp/packages/conn22v2407_standalone_jammy_R2024b.zip -d /usr/local && \
    chmod 755 /usr/local/conn22v2407_standalone/run_conn.sh && \
    chmod 755 /usr/local/conn22v2407_standalone/conn

RUN --mount=type=bind,source=packages,target=/tmp/packages \
    set -ex && \
    # FSL
    tar -xf /tmp/packages/fsl-6.0.7.18-jammy.tar.gz -C /usr/local/ && \
    # Git Scripts
    mkdir -p /home/brain/git && \
    cd /home/brain/git && \
    git clone https://gitlab.com/kytk/fs-scripts.git && \
    git clone https://gitlab.com/kytk/kn-scripts.git

#------------------------------------------------------------------------------
# Stage 2: The "Final" Stage
# - Starts from a clean Ubuntu base image.
# - Installs only runtime dependencies.
# - Copies the pre-built software from the "builder" stage.
# - Configures the user and environment.
#------------------------------------------------------------------------------
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Tokyo \
    DISPLAY=:1

# Part 1: Install runtime dependencies
RUN --mount=type=bind,source=packages,target=/tmp/packages \
    set -ex && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      # XFCE Desktop & VNC
      xfce4-session xfce4-panel xfwm4 xfce4-terminal xfce4-settings \
      xfdesktop4 xfce4-screenshooter xfce4-appfinder \
      shimmer-themes \
      thunar thunar-archive-plugin file-roller xdg-utils \
      gnome-icon-theme tango-icon-theme elementary-xfce-icon-theme \
      libgtk2.0-0 xinit \
      tightvncserver novnc websockify net-tools supervisor \
      x11vnc xvfb dbus-x11 sudo \
      dbus \
      # Python
      python3-pip python3-venv python3-tk python3-gpg \
      # Core Utilities
      wget tzdata iputils-ping less nano rsync locate git apt-utils apt-file \
      apturl at-spi2-core bc dc ca-certificates default-jre evince gedit \
      gnome-system-monitor gnome-system-tools baobab imagemagick \
      vim rename ntp tree unzip zip p7zip-full pigz csh tcsh gnupg meld \
      # Fonts & Themes
      software-properties-common fonts-noto fonts-noto-cjk \
      appmenu-gtk-module-common appmenu-gtk2-module libappmenu-gtk2-parser0 \
      # Apps & Libs
      gawk sed libopenblas-base \
      libjpeg62 libgtk2.0-0 language-pack-en gettext \
      libncurses5 && \
    apt-get install -y octave gnumeric && \
    cd /tmp/packages && \
    mkdir -p /home/brain/.config/xfce4/xfconf/xfce-perchannel-xml && \
    # AlizaMS installation
    apt install -y /tmp/packages/alizams_1.9.10+git0.95d7909-1+1.1_amd64.deb && \
    # Timezone setup
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata && \
    # Python package installation
    python3 -m pip install --upgrade pip && \
    pip install --no-cache-dir \
       numpy pandas matplotlib seaborn jupyter notebook gdcm \
       pydicom heudiconv nipype nibabel && \
    # Firefox setup
    install -d -m 0755 /etc/apt/keyrings && \
    wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | \
      gpg --dearmor -o /etc/apt/keyrings/packages.mozilla.org.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.gpg] https://packages.mozilla.org/apt mozilla main" | \
      tee /etc/apt/sources.list.d/mozilla.list > /dev/null && \
    echo 'Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000' | \
      tee /etc/apt/preferences.d/mozilla && \
    apt-get update && \
    apt-get install -y --no-install-recommends firefox && \
    xdg-mime default firefox.desktop text/html && \
    # Final apt cleanup for this layer
    apt-get clean && \
    apt-get autoremove -y --purge && \
    rm -rf /var/lib/apt/lists/*

# Part 2: Copy pre-built applications from the builder stage
# Part 2a: Copy small neuroimaging tools (~2-3GB)
COPY --from=builder /usr/local/MRIcroGL/ /usr/local/MRIcroGL/
COPY --from=builder /usr/local/dcm2niix/ /usr/local/dcm2niix/
COPY --from=builder /usr/local/mrtrix3/ /usr/local/mrtrix3/
COPY --from=builder /usr/local/ANTs/ /usr/local/ANTs/

# Part 2b: Copy FreeSurfer and MCR v97 (~8-10GB)
COPY --from=builder /usr/local/freesurfer/ /usr/local/freesurfer/
COPY --from=builder /home/brain/freesurfer/ /home/brain/freesurfer/

# Part 2c: Copy MATLAB MCR R2024b (~15-20GB)
COPY --from=builder /usr/local/MATLAB/ /usr/local/MATLAB/

# Part 2d: Copy SPM25 and CONN (~3-5GB)
COPY --from=builder /usr/local/spm25_standalone/ /usr/local/spm25_standalone/
COPY --from=builder /usr/local/conn22v2407_standalone/ /usr/local/conn22v2407_standalone/

# Part 2e: Copy FSL (~10-15GB)
COPY --from=builder /usr/local/fsl/ /usr/local/fsl/

# Part 2f: Copy git repositories and matlab startup
COPY --from=builder /home/brain/git/ /home/brain/git/
COPY --from=builder /home/brain/matlab/ /home/brain/matlab/

# Part 3: User setup and configuration
COPY deep_ocean.png /usr/share/backgrounds/
COPY bash_aliases /etc/skel/.bash_aliases
COPY bash_aliases /root/.bash_aliases
COPY bash_aliases /home/brain/.bash_aliases
COPY startup.m /home/brain/matlab/
RUN rm -f /usr/share/backgrounds/xfce/xfce*.*p*g && \
    chmod 644 /root/.bash_aliases && \
    chmod 644 /etc/skel/.bash_aliases

RUN set -ex && \
    sed -i "s/UI.initSetting('resize', 'off');/UI.initSetting('resize', 'local');/g" /usr/share/novnc/app/ui.js && \
    useradd -m -s /bin/bash brain && \
    echo "brain:lin4neuro" | chpasswd && \
    adduser brain sudo && \
    cp /etc/skel/.bashrc /home/brain/.bashrc && \
    echo '# Load .bashrc for bash login shells' > /home/brain/.profile && \
    echo 'if [ -n "$BASH_VERSION" ]; then' >> /home/brain/.profile && \
    echo '  . ~/.bashrc' >> /home/brain/.profile && \
    echo 'fi' >> /home/brain/.profile && \
    chmod 644 /home/brain/.bash_aliases /home/brain/.profile && \
    mkdir -p /home/brain/.vnc && \
    echo "lin4neuro" | vncpasswd -f > /home/brain/.vnc/passwd && \
    chmod 600 /home/brain/.vnc/passwd && \
    chown -R brain:brain /home/brain /usr/local/freesurfer/8.1.0/subjects \
          /usr/local/spm25_standalone /usr/local/conn22v2407_standalone

# Part 4: System cleanup
RUN set -ex && \
    # Purge removed package configs
    if [ $(dpkg -l | egrep ^rc | wc -l) -gt 0 ]; then \
      dpkg -l | awk '/^rc/ {print $2}' | xargs sudo dpkg --purge; \
    fi && \
    # Clean pip cache
    pip cache purge && \
    # Clear logs
    find /var/log/ -type f -exec cp -f /dev/null {} \; && \
    # Remove documentation and man pages
    #find /usr/share/doc -depth -type f ! -name copyright -delete && \
    #find /usr/share/doc -empty -delete && \
    #rm -rf /usr/share/man /usr/share/groff /usr/share/info \
    #       /usr/share/lintian /usr/share/linda /var/cache/man && \
    # Remove locales
    find /usr/share/locale -maxdepth 1 -mindepth 1 ! -name 'en*' -exec rm -r {} \;

# Part 5: MATLAB MCR cleanup
RUN set -ex && \
    # This part contains extensive cleanup for the MATLAB runtime.
    # It removes documentation, files for other platforms, development headers,
    # and unused toolboxes to significantly reduce its size.
    cd /usr/local/MATLAB/MCR/R2024b && \
    rm -rf help/ patents.txt trademarks.txt matlabruntime_license_agreement.pdf && \
    find . -type d -name "*doc*" -exec rm -rf {} + && \
    find . -type d -name "*example*" -exec rm -rf {} + && \
    find . -type d -name "*demo*" -exec rm -rf {} + && \
    find . -type d -name "*tutorial*" -exec rm -rf {} + && \
    find . -name "*.pdf" -delete && find . -name "*.html" -delete && find . -name "*.htm" -delete && \
    find . -name "*win32*" -delete && find . -name "*win64*" -delete && find . -name "*maci*" -delete && \
    find . -name "*Darwin*" -delete && find . -name "*.exe" -delete && find . -name "*.dll" -delete && \
    find . -name "*.dylib" -delete && \
    find . -name "*.h" -delete && find . -name "*.hpp" -delete && find . -name "*.c" -delete && \
    find . -name "*.cpp" -delete && find . -name "*.m~" -delete && find . -name "*.bak" -delete && \
    find . -name "*.log" -delete && find . -name "*.tmp" -delete && find . -name ".DS_Store" -delete && \
    cd toolbox && \
    rm -rf simulink* stateflow* sldv* slvnv* sl3d* slrt* sldo* rtw* simscape* simevents* simpowersys* \
           simrf* simbio* automotive* driving* vehicle* uav* lidar* radar* aerospace* satellite* \
           antenna* phased* finance* econ* risk* trading* robotics* nav* control* robust* fuzzy* \
           slcontrol* rf* mixed* serdes* antenna* eda* hdlcoder* hdlverifier* fixedpoint* vision* \
           audio* dsp* comm* wireless* nnet* deeplearning* reinforcementlearning* textanalytics* \
           predmaint* gads* optim* globaloptim* bioinfo* biograph* coder* gpucoder* polyspace* \
           matlab*test* sltest* coverage* requirements* appdesigner* uicomponents* instrument* \
           daq* imaq* opc* database* datafeed* spreadsheet* 2>/dev/null || true

# Part 6: Final configuration
RUN set -ex && \
    mkdir -p /home/brain/logs && \
    chmod 1777 /tmp && \
    mkdir -p /home/brain/.config/xfce4/terminal && \
    chown -R brain:brain /home/brain/.config && \
    chown -R brain:brain /home/brain/logs && \
    mkdir -p /home/brain/.dbus && \
    chown -R brain:brain /home/brain/.dbus

# Copy configuration files
COPY xfce4-desktop.xml /home/brain/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
COPY xfce4-panel.xml /home/brain/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
COPY terminalrc /home/brain/.config/xfce4/terminal/terminalrc
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY startup.sh /usr/local/bin/startup.sh

# Set final permissions and ownership
RUN chown brain:brain /home/brain/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml && \
    chown brain:brain /home/brain/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml && \
    chown brain:brain /home/brain/.config/xfce4/terminal/terminalrc && \
    chmod +x /usr/local/bin/entrypoint.sh && \
    chmod +x /usr/local/bin/startup.sh

# Expose port for noVNC
EXPOSE 6080

# startup.sh runs as ROOT first, then switches to brain user
ENV USER=brain

# Set the default command to run on container start
CMD ["/usr/local/bin/startup.sh"]
