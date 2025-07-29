#!/bin/bash

## Copyright (C) 2020-2025 Gaurav Raj
##
## Post-Installation Script For Berserk Arch, Executed by Calamare's `contextualprocess` module.

## ---------------------------------------------------------------------------------------

## Dirs ----------
USER=$(cat /etc/passwd | grep "/home" | cut -d: -f1 | head -1)
HOME_DIR="/home/${USER}"

## Remove Package ----------
_remove_pkg_if_installed() {
  pacman -Q "$1" &>/dev/null
  if [[ "$?" == 0 ]]; then
    echo "[*] Removing package : $1"
    pacman -Rnscu --noconfirm ${1}
  fi
}

## Remove File ----------
_remove_file_if_exist() {
  if [[ -e "$1" ]]; then
    echo "[*] Deleting file/folder : $1"
    rm -rf ${1}
  fi
}

## Remove Files & Packages ----------
_remove_for_de() {
  for _pkg in "${_pkgs_to_remove[@]}"; do
    _remove_pkg_if_installed ${_pkg}
  done

  for _file in "${_files_to_remove[@]}"; do
    _remove_file_if_exist ${_file}
  done
}

## ---------------------------------------------------------------------------------------

## Remove GNOME ----------
remove_gnome() {
  ## List Of Packages To Remove
  _pkgs_to_remove=('baobab'
    'decibels'
    'epiphany'
    'evince'
    'gdm'
    'gnome-backgrounds'
    'gnome-calculator'
    'gnome-calendar'
    'gnome-characters'
    'gnome-clocks'
    'gnome-color-manager'
    'gnome-connections'
    'gnome-console'
    'gnome-contacts'
    'gnome-control-center'
    'gnome-disk-utility'
    'gnome-font-viewer'
    'gnome-keyring'
    'gnome-logs'
    'gnome-maps'
    'gnome-menus'
    'gnome-music'
    'gnome-remote-desktop'
    'gnome-session'
    'gnome-settings-daemon'
    'gnome-shell'
    'gnome-software'
    'gnome-system-monitor'
    'gnome-text-editor'
    'gnome-tour'
    'gnome-user-docs'
    'gnome-user-share'
    'gnome-weather'
    'grilo-plugins'
    'loupe'
    'malcontent'
    'nautilus'
    'orca'
    'rygel'
    'simple-scan'
    'snapshot'
    'sushi'
    'tecla'
    'totem'
    'yelp'
    'd-spy'
    'dconf-editor'
    'ghex'
    'gnome-tweaks'
    'sysprof'
    'sddm'
    'sddm-kcm'
    'gnome-shell-extensions'
    'gnome-shell-extension-dash-to-dock'
    'berserk-config-gnome')

  ## List Of File & Dirs To Remove
  _files_to_remove=("$HOME_DIR"/.config/openbox)

  ## Remove Packages, File & Dirs
  _remove_for_de
}

## Remove XFCE ----------
remove_xfce() {
  # 'xfce4' 'xfce4-goodies'
  _pkgs_to_remove(
    'exo'
    'garcon'
    'xfce4-appfinder'
    'xfce4-panel'
    'xfce4-power-manager'
    'xfce4-session'
    'xfce4-settings'
    'xfce4-terminal'
    'xfconf'
    'xfdesktop'
    'xfwm4'
    'xfwm4-themes'
    'mousepad'
    'parole'
    'ristretto'
    'xfburn'
    'xfce4-artwork'
    'xfce4-battery-plugin'
    'xfce4-clipman-plugin'
    'xfce4-cpufreq-plugin'
    'xfce4-cpugraph-plugin'
    'xfce4-dict'
    'xfce4-diskperf-plugin'
    'xfce4-eyes-plugin'
    'xfce4-fsguard-plugin'
    'xfce4-genmon-plugin'
    'xfce4-mailwatch-plugin'
    'xfce4-mount-plugin'
    'xfce4-mpc-plugin'
    'xfce4-netload-plugin'
    'xfce4-notes-plugin'
    'xfce4-notifyd'
    'xfce4-places-plugin'
    'xfce4-pulseaudio-plugin'
    'xfce4-screensaver'
    'xfce4-screenshooter'
    'xfce4-sensors-plugin'
    'xfce4-smartbookmark-plugin'
    'xfce4-systemload-plugin'
    'xfce4-taskmanager'
    'xfce4-time-out-plugin'
    'xfce4-timer-plugin'
    'xfce4-verve-plugin'
    'xfce4-wavelan-plugin'
    'xfce4-weather-plugin'
    'xfce4-whiskermenu-plugin'
    'xfce4-xkb-plugin'
    'berserk-rofi'
    'berserk-polybar'
    )
  _files_to_remove=("$HOME_DIR"/.config/xfce4)
  _remove_for_de
}

## ---------------------------------------------------------------------------------------

## Install Openbox ----------
install_gnome() {
  echo "[*] Installing GNOME DE..."
  remove_xfce
}

## Install Bspwm ----------
install_xfce() {
  echo "[*] Installing XFCE DE..."
  remove_gnome
}

## ---------------------------------------------------------------------------------------

## Execute In Target ----------
if [[ "$1" == '--gnome' ]]; then
  install_gnome
elif [[ "$1" == '--xfce' ]]; then
  install_xfce
fi
