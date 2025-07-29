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
    pacman -Rnsdd --noconfirm ${1}
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
  _pkgs_to_remove=('gnome'
    'd-spy'
    'dconf-editor'
    'ghex'
    'gnome-tweaks'
    'sysprof'
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
  _pkgs_to_remove=('xfce4' 'xfce4-goodies' 'berserk-rofi' 'berserk-config-xfce')
  _files_to_remove=("$HOME_DIR"/.config/bspwm)
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
