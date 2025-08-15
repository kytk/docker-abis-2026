## Dockerfile to make "docker-abis-2026"
## This file makes a container image of docker-abis-2026
## K. Nemoto 15 Aug 2025

FROM ubuntu:22.04

# Environmental variables
# System configuration
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Tokyo

# Display settings
ENV RESOLUTION=1920x1080x24

# User settings
ENV USER=brain

# Path configuration
ENV parts=/etc/skel/git/lin4neuro-jammy/lin4neuro-parts \
    BASE_URL="http://www.lin4neuro.net/lin4neuro/neuroimaging_software_packages"

########## Part 1. Base of Container ##########
# Install basic utilities and X11
RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
       xfce4 \
       xfce4-terminal \
       xfce4-indicator-plugin  \
       xfce4-statusnotifier-plugin  \
       xfce4-screenshooter \
       elementary-xfce-icon-theme \
       gnome-icon-theme \
       librsvg2-common \
       gtk-update-icon-cache \
       tango-icon-theme \
       yaru-theme-icon \
       shimmer-themes \
       xinit \
       build-essential  \
       dkms \
       thunar-archive-plugin \
       file-roller \
       gawk \
       sed \
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
       python3-pip \
       python3-venv \
       python3-dev \
       python3-tk \
       python3-gpg \
       tzdata \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* /var/tmp/* 

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

# Install utilities
RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
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
       baobab \
       libopenblas-base \
       apturl \
       dmz-cursor-theme \
       p7zip-full \
       gnupg \
       eog \
       meld \
       libjpeg62 \
       software-properties-common \
       fonts-noto \
       fonts-noto-cjk \
       fonts-ipafont \
       fonts-ipafont-gothic \
       fonts-ipafont-mincho \
       pigz \
       appmenu-gtk-module-common \
       appmenu-gtk2-module \
       libappmenu-gtk2-parser0 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* /var/tmp/* 

# Libreoffice calc and writer
RUN set -ex \
    && apt-get update \
    && apt-get -y install \
       libreoffice-calc \
       libreoffice-writer \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* /var/tmp/* 

# Install Google-chrome
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
 && apt install -y ./google-chrome-stable_current_amd64.deb \
 && rm google-chrome-stable_current_amd64.deb

########## End of Part 1 ##########

########## Part 2. Lin4Neuro ##########
RUN set -ex \
    && mkdir /etc/skel/git && cd /etc/skel/git \
    && git clone https://gitlab.com/kytk/lin4neuro-jammy.git \
    # Icons and Applications
    && mkdir -p /etc/skel/.local/share \ 
    && cp -r ${parts}/local/share/icons /etc/skel/.local/share/ \
    && cp -r ${parts}/local/share/applications /etc/skel/.local/share/ \
    # Customized menu
    && mkdir -p /etc/skel/.config/menus \
    && cp ${parts}/config/menus/xfce-applications.menu /etc/skel/.config/menus \
    # Customized panel, desktop, and theme
    && cp -r ${parts}/config/xfce4 /etc/skel/.config/ \
    && cp /usr/share/applications/firefox.desktop \
          /etc/skel/.config/xfce4/panel/launcher-6/ \
    && rm /etc/skel/.config/xfce4/panel/launcher-6/google-chrome.desktop \
    && rm /etc/skel/.config/xfce4/panel/launcher-6/firefox.desktop \
    # Desktop files
    && cp -r ${parts}/local/share/applications /etc/skel/.local/share/ \
    # Neuroimaging.directory
    && mkdir -p /etc/skel/.local/share/desktop-directories \
    && cp ${parts}/local/share/desktop-directories/Neuroimaging.directory \
       /etc/skel/.local/share/desktop-directories \
    # Background image and remove an unnecessary image file
    && cp ${parts}/backgrounds/deep_ocean.png /usr/share/backgrounds \
    && rm /usr/share/backgrounds/xfce/xfce-*.*p*g

COPY xfce4-panel.xml xfce4-desktop.xml \
     /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml

# .bash_aliases
COPY bash_aliases /etc/skel/.bash_aliases
COPY bash_aliases /root/.bash_aliases
RUN chmod 644 /root/.bash_aliases \
    && chmod 644 /etc/skel/.bash_aliases

########## End of Part 2 ##########

##### Part 3. Neuroimaging and related Software packages #####

RUN set -ex \
    # Install and configure Mango
    && cd /tmp/ \
    && wget ${BASE_URL}/mango_unix.zip \
    && unzip mango_unix.zip -d /usr/local/ \
    && rm mango_unix.zip \
    \
    # Install and configure MRIcroGL
    && cd /tmp/ \
    && wget ${BASE_URL}/MRIcroGL_linux.zip \
    && unzip MRIcroGL_linux.zip -d /usr/local/ \
    && rm MRIcroGL_linux.zip \
    \
    # Install Octave and AlizaMS
    && apt-get install -y octave \
    && cd /tmp/ \
    && wget ${BASE_URL}/alizams_1.9.10+git0.95d7909-1+1.1_amd64.deb \
    && apt install -y ./alizams_1.9.10+git0.95d7909-1+1.1_amd64.deb \
    && rm alizams_1.9.10+git0.95d7909-1+1.1_amd64.deb \
    && sed -i 's/NoDisplay=true/NoDisplay=false/' \
              /etc/skel/.local/share/applications/alizams.desktop \
    \
    # Install and configure dcm2niix
    && mkdir /usr/local/dcm2niix \
    && cd /tmp/ \
    && wget ${BASE_URL}/dcm2niix_lnx.zip \
    && unzip dcm2niix_lnx.zip -d /usr/local/dcm2niix \
    && rm dcm2niix_lnx.zip \
    \
    # Install and configure MRtrix3 and ANTs
    && cd /tmp/ \
    && wget ${BASE_URL}/mrtrix3_jammy.zip \
    && unzip mrtrix3_jammy.zip -d /usr/local \
    && rm mrtrix3_jammy.zip \
    && wget ${BASE_URL}/ANTs-jammy.zip \
    && unzip ANTs-jammy.zip -d /usr/local \
    && rm ANTs-jammy.zip 

RUN set -ex \
    # Install MATLAB Runtime
    && cd /tmp/ \
    && mkdir mcr_r2024b && cd mcr_r2024b \
    && wget ${BASE_URL}/MATLAB_Runtime_R2024b_Update_1_glnxa64.zip \
    && unzip MATLAB_Runtime_R2024b_Update_1_glnxa64.zip \
    && rm MATLAB_Runtime_R2024b_Update_1_glnxa64.zip \
    && ./install -mode silent -agreeToLicense yes -destinationFolder /usr/local/MATLAB/MCR/ \
    && cd /tmp/ && rm -rf mcr_r2024b \
    \
    # Install and configure SPM12
    && cd /tmp/ \
    && wget ${BASE_URL}/spm12_standalone_jammy_R2024b.zip \
    && unzip spm12_standalone_jammy_R2024b.zip -d /usr/local/ \
    && rm spm12_standalone_jammy_R2024b.zip \
    && chmod 755 /usr/local/spm12_standalone/run_spm12.sh \
    && chmod 755 /usr/local/spm12_standalone/spm12 \
    \
    # Install and configure CONN
    && cd /tmp/ \
    && wget ${BASE_URL}/conn22v2407_standalone_jammy_R2024b.zip \
    && unzip conn22v2407_standalone_jammy_R2024b.zip -d /usr/local \
    && rm conn22v2407_standalone_jammy_R2024b.zip \
    && chmod 755 /usr/local/conn22v2407_standalone/run_conn.sh \
    && chmod 755 /usr/local/conn22v2407_standalone/conn 

RUN set -ex \
    # Install and configure FSL
    && cd /tmp/ \
    && wget ${BASE_URL}/fsl-6.0.7.18-jammy.tar.gz \
    && tar -xvf fsl-6.0.7.18-jammy.tar.gz -C /usr/local/ \
    && rm fsl-6.0.7.18-jammy.tar.gz \
    && sed -i 's/NoDisplay=true/NoDisplay=false/' \
              /etc/skel/.local/share/applications/fsleyes.desktop

# FSL original script
# RUN cd /tmp && \
#    wget https://fsl.fmrib.ox.ac.uk/fsldownloads/fslinstaller.py && \
#    /usr/bin/python3 fslinstaller.py -d /usr/local/fsl && \

#RUN set -ex \
#    # Install FreeSurfer 8.0.1
#    cd /tmp/ \
#    && wget ${BASE_URL}/freesurfer_ubuntu22-8.1.0_amd64.deb \
#    # && wget https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/8.1.0/freesurfer_ubuntu22-8.1.0_amd64.deb
#    && apt install ./freesurfer_ubuntu22-8.1.0_amd64.deb \
#    && rm freesurfer_ubuntu22-8.1.0_amd64.deb \
#    && mkdir -p /etc/skel/freesurfer/8.0.1 \
#    && cp -rs /usr/local/freesurfer/8.0.1/subjects /etc/skel/freesurfer/8.0.1/

# fs-scripts and kn-scripts
RUN set -ex \
    && cd /etc/skel/git \
    && git clone https://gitlab.com/kytk/fs-scripts.git \
    && git clone https://gitlab.com/kytk/kn-scripts.git 

########## End of Part 3 ##########

########## Part 4. VNC ##########
# Set up VNC, create a new user, and configure software permissions
RUN set -ex \
    # Set up VNC for root
    && mkdir -p /root/.vnc \
    && echo "lin4neuro" | vncpasswd -f > /root/.vnc/passwd \
    && chmod 600 /root/.vnc/passwd \
    # Create a new user
    && useradd -m -s /bin/bash brain \
    && echo "brain:lin4neuro" | chpasswd \
    && adduser brain sudo \
    # Set up VNC for the new user
    && mkdir -p /home/brain/.vnc \
    && echo "lin4neuro" | vncpasswd -f > /home/brain/.vnc/passwd \
    && chmod 600 /home/brain/.vnc/passwd \
    && chown -R brain:brain /home/brain/.vnc \
    # Create a directory for supervisor logs
    && mkdir -p /home/brain/logs \
    && chown -R brain:brain /home/brain/logs \
    # SPM settings
    && chown -R brain:brain /usr/local/spm12_standalone \
    && cd /usr/local/spm12_standalone \
    && chmod 755 run_spm12.sh spm12 \
    # CONN settings
    && chown -R brain:brain /usr/local/conn22v2407_standalone \
    && cd /usr/local/conn22v2407_standalone \
    && chmod 755 run_conn.sh conn 

# Copy supervisord configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# expose port 6080
EXPOSE 6080

# Healthcheck
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
  CMD nc -z localhost 6080 || exit 1

# Switch to the new user
USER brain

## Prepare FreeSurfer
#RUN set -ex \
#    && mkdir -p ~/freesurfer/8.0.1 \
#    && cp -r /usr/local/freesurfer/8.0.1/subjects ~/freesurfer/8.0.1/

# Uncheck "Show unsafe paste dialog"
COPY terminalrc /home/brain/.config/xfce4/terminal/

# Entrypoint
COPY --chown=brain:brain docker-entrypoint.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

##### End of Part 4 ##########

