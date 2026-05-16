#!/usr/bin/env bash
## Run

if [[ "$DESKTOP_SESSION" == i3* ]] || [ -n "$I3SOCK" ]; then
  TRANSPARENCY="screenshot"
else
  TRANSPARENCY="real"
fi

rofi \
  -show drun \
  -theme "$HOME/.config/rofi/main.rasi" \
  -theme-str "window { transparency: \"$TRANSPARENCY\"; }"
