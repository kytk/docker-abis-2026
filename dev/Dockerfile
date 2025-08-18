## Dockerfile to make "docker-abis-2026"
## This file makes a container image of docker-abis-2026
## K. Nemoto 18 Aug 2025

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
      tzdata

# Timezone
RUN set -ex \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && dpkg-reconfigure -f noninteractive tzdata

# Python
RUN set -ex \
    && python3 -m pip install --upgrade pip \
    && pip install --no-cache-dir numpy pandas pydicom gdcm \
       heudiconv nipype nibabel jupyter notebook \
       bash_kernel octave_kernel \
    && python3 -m bash_kernel.install

# Utilities
RUN set -ex && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
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
      imagemagick \
      rename \
      ntp \
      tree \
      unzip \
      vim  \
      zip \
      tcsh \
      libopenblas-base \
      apturl \
      dmz-cursor-theme \
      p7zip-full \
      gnupg \
      meld \
      libjpeg62 \
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
      sed 

# Firefox
RUN set -ex \
    install -d -m 0755 /etc/apt/keyrings \
    && wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | \
      gpg --dearmor -o /etc/apt/keyrings/packages.mozilla.org.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.gpg] https://packages.mozilla.org/apt mozilla main" | tee /etc/apt/sources.list.d/mozilla.list > /dev/null \
    && echo 'Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000'|\
      tee /etc/apt/preferences.d/mozilla \
    && apt-get update \
    && apt-get install -y firefox \
    && xdg-mime default firefox.desktop text/html

COPY deep_ocean.png /usr/share/backgrounds/
RUN rm /usr/share/backgrounds/xfce/xfce*.*p*g

# .bash_aliases
COPY bash_aliases /etc/skel/.bash_aliases
COPY bash_aliases /root/.bash_aliases
RUN chmod 644 /root/.bash_aliases && \
    chmod 644 /etc/skel/.bash_aliases


##### Part 2. noVNC #####

# make local scaling the default
RUN sed -i "s/UI.initSetting('resize', 'off');/UI.initSetting('resize', 'local');/g" /usr/share/novnc/app/ui.js

# Create a new user
RUN useradd -m -s /bin/bash brain && \
    echo "brain:lin4neuro" | chpasswd && \
    adduser brain sudo

# Set up VNC for the new user
RUN mkdir -p /home/brain/.vnc && \
    echo "lin4neuro" | vncpasswd -f > /home/brain/.vnc/passwd && \
    chmod 600 /home/brain/.vnc/passwd && \
    chown -R brain:brain /home/brain/.vnc


##### Part 3. Neuroimaging and related Software packages #####

# Copy neuroimaging software packages to /tmp
COPY packages/* /tmp/

# Mango
RUN set -ex  && \
    cd /tmp/ && \
    unzip mango_unix.zip -d /usr/local/ && \
    rm mango_unix.zip

# MRIcroGL
RUN set -ex && \
    cd /tmp/ && \
    unzip MRIcroGL_linux.zip -d /usr/local/ && \
    rm MRIcroGL_linux.zip

# dcm2niix
RUN set -ex && \
    mkdir -p /usr/local/dcm2niix && \
    cd /tmp/ && \
    unzip dcm2niix_lnx.zip -d /usr/local/dcm2niix && \
    rm dcm2niix_lnx.zip

# MRtrix3
RUN set -ex && \
    cd /tmp/ && \
    unzip mrtrix3_jammy.zip -d /usr/local && \
    rm mrtrix3_jammy.zip

# ANTs
RUN set -ex && \
    cd /tmp/ && \
    unzip ANTs-jammy.zip -d /usr/local && \
    rm ANTs-jammy.zip

# AlizaMS
RUN set -ex && \
    cd /tmp/ && \
    dpkg -i ./alizams_1.9.10+git0.95d7909-1+1.1_amd64.deb || true && \
    apt-get install -f -y 

# Matlab MCR R2024b
RUN set -ex && \
    cd /tmp/ && \
    mkdir -p mcr_r2024b && \
    mv MATLAB_Runtime_R2024b_Update_1_glnxa64.zip mcr_r2024b && \
    cd mcr_r2024b && \
    unzip MATLAB_Runtime_R2024b_Update_1_glnxa64.zip && \
    ./install -mode silent -agreeToLicense yes -destinationFolder \
      /usr/local/MATLAB/MCR/ && \
    cd /tmp/ && \
    rm -rf mcr_2024b

# SPM25
RUN set -ex && \
    cd /tmp/ && \
    unzip spm_standalone_25.01.02_Linux.zip && \
    mv spm_standalone spm25_standalone && \
    mv spm25_standalone /usr/local && \
    chown -R brain:brain /usr/local/spm25_standalone && \
    rm spm_standalone_25.01.02_Linux.zip

# CONNv2407
RUN set -ex && \
    cd /tmp/ && \
    unzip conn22v2407_standalone_jammy_R2024b.zip -d /usr/local && \
    chown -R brain:brain /usr/local/conn22v2407_standalone && \
    chmod 755 /usr/local/conn22v2407_standalone/run_conn.sh && \
    chmod 755 /usr/local/conn22v2407_standalone/conn && \
    rm conn22v2407_standalone_jammy_R2024b.zip 

# FSL
RUN set -ex && \
    cd /tmp/ && \
    tar -xvf fsl-6.0.7.18-jammy.tar.gz -C /usr/local/ && \
    rm fsl-6.0.7.18-jammy.tar.gz

# FreeSurfer 8.1.0
RUN set -ex && \
    apt-get install -y \
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
    cd /tmp/ && \
    dpkg -i ./freesurfer_ubuntu22-8.1.0_amd64.deb || true && \
    apt-get install -f -y && \
    dpkg --configure -a && \
    mkdir -p /home/brain/freesurfer/8.1.0 && \
    cp -rs /usr/local/freesurfer/8.1.0/subjects /home/brain/freesurfer/8.1.0/

# fs-scripts and kn-scripts
RUN set -ex && \
    mkdir -p /home/brain//git && \
    cd /home/brain/git && \
    git clone https://gitlab.com/kytk/fs-scripts.git && \
    git clone https://gitlab.com/kytk/kn-scripts.git && \
    chown -R brain:brain /home/brain/git

# Cleanup
RUN set -ex && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* /var/tmp/* 

##### Part 4. User #####

# Create a directory for supervisor logs
RUN mkdir -p /home/brain/logs && \
    chown -R brain:brain /home/brain/logs

# Disable screensaver
RUN echo '\n\
# Disable screensaver\n\
xset s off' >> /home/brain/.bashrc

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

ENV DISPLAY=:1

EXPOSE 6080

# Switch to the new user
USER brain
ENV USER=brain

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

