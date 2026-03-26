# user, host, full path, and time/date
# on two lines for easier vgrepping
# entry in a nice long thread on the Arch Linux forums: https://bbs.archlinux.org/viewtopic.php?pid=521888#p521888

autoload -Uz colors && colors

autoload -Uz vcs_info
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr '%F{red}*'   # display this when there are unstaged changes
zstyle ':vcs_info:*' stagedstr '%F{yellow}+'  # display this when there are staged changes
zstyle ':vcs_info:*' actionformats ' - %B%F{4}[%F{5}(%F{2}%b%F{3}|%F{1}%a%c%u%m%F{5})%F{4}]%f'
zstyle ':vcs_info:*' formats ' - %B%F{4}[%F{5}(%F{2}%b%c%u%m%F{5})%F{4}]%f'
zstyle ':vcs_info:svn:*' branchformat '%b'
zstyle ':vcs_info:svn:*' actionformats ' - %B%F{4}[%F{5}(%F{2}%b%F{1}:%{3}%i%F{3}|%F{1}%a%c%u%m%F{5})%F{4}]%f'
zstyle ':vcs_info:svn:*' formats ' - %B%F{4}[%F{5}(%F{2}%b%F{1}:%F{3}%i%c%u%m%F{5})%F{4}]%f'
zstyle ':vcs_info:*' enable git cvs svn
zstyle ':vcs_info:git*+set-message:*' hooks untracked-git

+vi-untracked-git() {
  if command git status --porcelain 2>/dev/null | command grep -q '??'; then
    hook_com[misc]='%F{red}?'
  else
    hook_com[misc]=''
  fi
}

gkali_precmd() {
  vcs_info
}

autoload -U add-zsh-hook
add-zsh-hook precmd gkali_precmd

# Virtual ENV Info
virtenv_prompt() {
  [[ -n "${VIRTUAL_ENV:-}" ]] || return
  echo "%F{4}─(%F{3}${VIRTUAL_ENV:t}%F{4})─"
}

precmd() {
  venv_info=$(virtenv_prompt)
}

PROMPT=$'%{\e[0;34m%}%B┌─${venv_info}─(%b%{\e[0m%}%{\e[1;32m%}%n%{\e[1;34m%}@%{\e[0m%}%{\e[0;36m%}%m%{\e[0;34m%}%B)%b%{\e[0m%} - %b%{\e[0;34m%}%B[%b%{\e[1;37m%}%~%{\e[0;34m%}%B]%b%{\e[0m%} - %{\e[0;34m%}%B[%b%{\e[0;33m%}%!%{\e[0;34m%}%B]%b%{\e[0m%}${vcs_info_msg_0_}
%{\e[0;34m%}%B└─%B[%{\e[1;35m%}$%{\e[0;34m%}%B]%{\e[0m%}%b '
RPROMPT='[%*]'
PS2=$' \e[0;34m%}%B>%{\e[0m%}%b '
