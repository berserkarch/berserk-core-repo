#!/usr/bin/env bash

# Current Theme
theme="$HOME/.config/rofi/powermenu/style.rasi"

# Transparency detection
if [[ "$DESKTOP_SESSION" == i3* ]] || [ -n "$I3SOCK" ]; then
  TRANSPARENCY="screenshot"
else
  TRANSPARENCY="real"
fi

# CMDs
lastlogin="$(last $USER | head -n1 | tr -s ' ' | cut -d' ' -f5,6,7)"
uptime="$(uptime -p | sed -e 's/up //g')"
host=$(cat /etc/hostname)

# Options
hibernate=''
shutdown=''
reboot=''
lock=''
suspend=''
logout=''
yes=''
no=''

# Rofi CMD
rofi_cmd() {
  rofi -dmenu \
    -p " $USER@$host" \
    -mesg " Last Login: $lastlogin |  Uptime: $uptime" \
    -theme-str "window { transparency: \"$TRANSPARENCY\"; }" \
    -theme ${theme}
}

# Pass variables to rofi dmenu
run_rofi() {
  echo -e "$lock\n$suspend\n$logout\n$hibernate\n$reboot\n$shutdown" | rofi_cmd
}

# Execute Command
run_cmd() {
  if [[ $1 == '--shutdown' ]]; then
    systemctl poweroff
  elif [[ $1 == '--reboot' ]]; then
    systemctl reboot
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
    elif [[ "$DESKTOP_SESSION" == i3* ]] || [ -n "$I3SOCK" ]; then
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
  fi
  ;;
$suspend)
  run_cmd --suspend
  ;;
$logout)
  run_cmd --logout
  ;;
esac
