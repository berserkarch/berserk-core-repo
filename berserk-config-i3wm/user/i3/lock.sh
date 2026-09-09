#!/usr/bin/env bash
# Themed i3lock-color screen — matches the tokyonight / dwm bar palette used by
# the quickshell bar, i3 window theme, dmenu and dunst. Called by xss-lock.
#
# Palette (tokyonight):
#   bg      #1a1b26   fg bright #c0caf5   dim/comment #565f73
#   blue    #7aa2f7   green     #9ece6a   yellow #e0af68   red #f7768e
#
# rrggbbaa — trailing two hex digits are alpha. Solid bg via -c (no image/blur,
# so it's instant under llvmpipe software rendering in the VM).

exec i3lock \
    --nofork \
    --ignore-empty-password \
    --clock --force-clock --indicator \
    -c 1a1b26 \
    \
    --radius=110 \
    --ring-width=7 \
    --inside-color=1a1b26e6 \
    --ring-color=7aa2f7ff \
    --insidever-color=1a1b26e6 \
    --ringver-color=e0af68ff \
    --insidewrong-color=1a1b26e6 \
    --ringwrong-color=f7768eff \
    --line-color=00000000 \
    --separator-color=00000000 \
    --keyhl-color=9ece6aff \
    --bshl-color=f7768eff \
    \
    --time-str="%H:%M" \
    --date-str="%A, %d %B" \
    --time-color=c0caf5ff \
    --date-color=565f73ff \
    --time-font="Iosevka" \
    --date-font="Iosevka" \
    --time-size=34 \
    --date-size=15 \
    \
    --greeter-text=" berserkarch locked" \
    --greeter-color=7aa2f7ff \
    --greeter-font="Iosevka" \
    --greeter-size=15 \
    --greeter-pos="w/2:h/2+180" \
    \
    --verif-text="verifying…" \
    --wrong-text="denied" \
    --noinput-text="" \
    --verif-color=e0af68ff \
    --wrong-color=f7768eff \
    --modif-color=f7768eff \
    --layout-color=565f73ff \
    --verif-font="Iosevka" \
    --wrong-font="Iosevka" \
    "$@"
