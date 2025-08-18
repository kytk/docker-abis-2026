FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    xfce4 \
    xfce4-terminal \
    xfce4-indicator-plugin  \
    xfce4-clipman \
    xfce4-clipman-plugin \
    xfce4-statusnotifier-plugin  \
    xfce4-screenshooter \
    lightdm \
    lightdm-gtk-greeter \
    lightdm-gtk-greeter-settings \
    shimmer-themes \
    xinit \
    build-essential  \
    dkms \
    thunar-archive-plugin \
    file-roller \
    gawk \
    xdg-utils \ 
    tightvncserver \
    novnc \
    websockify \
    net-tools \
    curl \
    supervisor \
    x11vnc \
    xvfb \
    dbus-x11 \
    rename \
    sudo \
    wget \
    vim \
    gedit \
    gnupg

RUN apt-get install -y --no-install-recommends \
    fonts-noto fonts-noto-cjk

COPY deep_ocean.png /usr/share/backgrounds
RUN rm /usr/share/backgrounds/xfce/xfce*.*p*g

# make local scaling the default
RUN sed -i "s/UI.initSetting('resize', 'off');/UI.initSetting('resize', 'local');/g" /usr/share/novnc/app/ui.js

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

#WORKDIR /tmp/fsl-install

# Copy files to /tmp
COPY packages/fsl-6.0.7.18-jammy.tar.gz /tmp/


# Install and configure FSL
RUN set -ex \
    && cd /tmp/ \
    && tar -xvf fsl-6.0.7.18-jammy.tar.gz -C /usr/local/ \
    && rm fsl-6.0.7.18-jammy.tar.gz

# Cleanup
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a new user
RUN useradd -m -s /bin/bash brain && \
    echo "brain:lin4neuro" | chpasswd && \
    adduser brain sudo

# Set up VNC for the new user
RUN mkdir -p /home/brain/.vnc && \
    echo "lin4neuro" | vncpasswd -f > /home/brain/.vnc/passwd && \
    chmod 600 /home/brain/.vnc/passwd && \
    chown -R brain:brain /home/brain/.vnc

# Create a directory for supervisor logs
RUN mkdir -p /home/brain/logs && \
    chown -R brain:brain /home/brain/logs

# FSL profile setting
RUN echo '\n\
# FSL Setup\n\
FSLDIR=/usr/local/fsl\n\
PATH=${FSLDIR}/share/fsl/bin:${PATH}\n\
export FSLDIR PATH\n\
. ${FSLDIR}/etc/fslconf/fsl.sh' >> /home/brain/.bashrc

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
