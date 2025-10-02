FROM quay.io/fedora/fedora-bootc:42

RUN mkdir -p /var/roothome

RUN echo "fedora" > /etc/hostname

RUN dnf install -y @xfce-desktop-environment && \
    dnf install -y lightdm xguest firefox libreoffice labwc wlroots && \
    systemctl enable lightdm --force && \
    systemctl set-default graphical.target && \
    dnf clean all

RUN bootc container lint