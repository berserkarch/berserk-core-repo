#!/bin/bash

## Copyright (C) 2020-2025 Gaurav Raj
##
## Post-Installation Script For Berserk Arch, Executed by Calamare's `contextualprocess` module.

## ---------------------------------------------------------------------------------------

## Dirs ----------
USER=$(cat /etc/passwd | grep "/home" | cut -d: -f1 | head -1)
HOME_DIR="/home/${USER}"

xfce_pkgs=('xfce4' 'xfce4-battery-plugin' 'xfce4-datetime-plugin' 'xfce4-mount-plugin' 'xfce4-netload-plugin' 'xfce4-notifyd' 'xfce4-pulseaudio-plugin' 'xfce4-screensaver' 'xfce4-screenshooter' 'xfce4-taskmanager' 'xfce4-wavelan-plugin' 'xfce4-weather-plugin' 'xfce4-whiskermenu-plugin' 'xfce4-xkb-plugin' 'berserk-config-xfce')

openbox_pkgs=('obmenu-generator' 'berserk-config-openbox' 'openbox' 'obconf-qt' 'xcompmgr' 'nitrogen' 'dunst')

## Install Packages ----------
_install_packages() {
  local -n pkg_array=$1
  echo "[*] Installing packages : ${pkg_array[*]}"
  pacman -S --noconfirm --needed "${pkg_array[@]}"
}

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

## Remove XFCE ----------
remove_xfce() {
  ## Use the top array for packages to remove
  _pkgs_to_remove=("${xfce_pkgs[@]}")
  _files_to_remove=("$HOME_DIR"/.config/xfce4)
  _remove_for_de
}

## Remove OpenBox ----------
remove_openbox() {
  ## Use the top array for packages to remove
  _pkgs_to_remove=("${openbox_pkgs[@]}")
  _files_to_remove=("$HOME_DIR"/.config/openbox)
  _remove_for_de
}

## ---------------------------------------------------------------------------------------

## Install XFCE ----------
install_xfce() {
  echo "[*] Installing XFCE DE..."
  remove_openbox
  rm -rf "$HOME_DIR/.config/xfce4"
  cp -r /usr/share/berserkarch/home/skel/.config "$HOME_DIR/"
  chown -R $USER:$USER "$HOME_DIR/.config"
  sed -i 's|Session=.*|Session=/usr/share/xsessions/xfce.desktop|' /var/lib/sddm/state.conf
}

## Install XFCE ----------
install_openbox() {
  echo "[*] Installing OpenBox WM..."
  remove_xfce
}

## ---------------------------------------------------------------------------------------

## Execute In Target ----------
if [[ "$1" == '--xfce' ]]; then
  install_xfce
elif [[ "$1" == '--openbox' ]]; then
  install_openbox
fi
