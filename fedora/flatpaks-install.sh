#!/bin/bash

#Set timezone based on location
timedatectl set-timezone $(wget -qO - http://ip-api.com/line?fields=timezone)

# Install Flatpak applications (Thunderbird is only available for x86_64)
flatpak install -y --noninteractive flathub org.mozilla.firefox
flatpak install -y --noninteractive flathub org.gimp.GIMP
flatpak install -y --noninteractive flathub org.libreoffice.LibreOffice
flatpak install -y --noninteractive flathub org.mozilla.Thunderbird
flatpak install -y --noninteractive flathub org.gnome.Rhythmbox3
flatpak install -y --noninteractive flathub org.videolan.VLC
flatpak install -y --noninteractive flathub com.vscodium.codium
