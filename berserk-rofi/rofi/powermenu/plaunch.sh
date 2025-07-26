#!/usr/bin/env bash

# Current Theme
theme="$HOME/.config/rofi/powermenu/style.rasi"

# CMDs
lastlogin="$(last $USER | head -n1 | tr -s ' ' | cut -d' ' -f5,6,7)"
uptime="$(uptime -p | sed -e 's/up //g')"
host=$(cat /etc/hostname)

# Options
hibernate=''
shutdown=''
reboot=''
lock=''
suspend=''
logout=''
yes=''
no=''

# Rofi CMD
rofi_cmd() {
  rofi -dmenu \
    -p " $USER@$host" \
    -mesg " Last Login: $lastlogin |  Uptime: $uptime" \
    -theme ${theme}
}

# Pass variables to rofi dmenu
run_rofi() {
  echo -e "$lock\n$suspend\n$logout\n$hibernate\n$reboot\n$shutdown" | rofi_cmd
}

# Execute Command
run_cmd() {
  if [[ $1 == '--shutdown' ]]; then
    xfce4-session-logout --halt
  elif [[ $1 == '--reboot' ]]; then
    xfce4-session-logout --reboot
  elif [[ $1 == '--hibernate' ]]; then
    xfce4-session-logout --hibernate
  elif [[ $1 == '--suspend' ]]; then
    xfce4-session-logout --suspend
  elif [[ $1 == '--logout' ]]; then
    if [[ "$DESKTOP_SESSION" == 'xfce' ]]; then
      xfce4-session-logout --logout
    elif [[ "$DESKTOP_SESSION" == 'openbox' ]]; then
      openbox --exit
    elif [[ "$DESKTOP_SESSION" == 'bspwm' ]]; then
      bspc quit
    elif [[ "$DESKTOP_SESSION" == 'i3' ]]; then
      i3-msg exit
    elif [[ "$DESKTOP_SESSION" == 'plasma' ]]; then
      qdbus org.kde.ksmserver /KSMServer logout 0 0 0
    fi
  fi
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
$shutdown)
  run_cmd --shutdown
  ;;
$reboot)
  run_cmd --reboot
  ;;
$hibernate)
  run_cmd --hibernate
  ;;
$lock)
  if [[ -x '/usr/bin/xflock4' ]]; then
    xflock4
  # elif [[ -x '/usr/bin/betterlockscreen' ]]; then
  # 	betterlockscreen -l
  # elif [[ -x '/usr/bin/i3lock' ]]; then
  # 	i3lock
  fi
  ;;
$suspend)
  run_cmd --suspend
  ;;
$logout)
  run_cmd --logout
  ;;
esac
