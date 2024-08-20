function fzf-brew() {
  ######################
  ### Option Parser
  ######################

  local __parse_options (){
    local prompt="$1" && shift
    local option_list
    if [[ "$SHELL" == *"/bin/zsh" ]]; then
      option_list=("$@")
    elif [[ "$SHELL" == *"/bin/bash" ]]; then
      local -n arr_ref=$1
      option_list=("${arr_ref[@]}")
    fi

    ### Select the option
    selected_option=$(printf "%s\n" "${option_list[@]}" | fzf --ansi --prompt="${prompt} > ")
    if [[ -z "$selected_option" || "$selected_option" =~ ^[[:space:]]*$ ]]; then
      return 1
    fi

    ### Normalize the option list
    local option_list_normal=()
    for option in "${option_list[@]}"; do
        # Remove $(tput bold) and $(tput sgr0) from the string
        option_normalized="${option//$(tput bold)/}"
        option_normalized="${option_normalized//$(tput sgr0)/}"
        # Add the normalized string to the new array
        option_list_normal+=("$option_normalized")
    done
    ### Get the index of the selected option
    index=$(printf "%s\n" "${option_list_normal[@]}" | grep -nFx "$selected_option" | cut -d: -f1)
    if [ -z "$index" ]; then
      return 1
    fi

    ### Generate the command
    command=""
    if [[ "$SHELL" == *"/bin/zsh" ]]; then
      command="${option_list_normal[$index]%%:*}"
    elif [[ "$SHELL" == *"/bin/bash" ]]; then
      command="${option_list_normal[$index-1]%%:*}"
    else
      echo "Error: Unsupported shell. Please use bash or zsh to use fzf-brew."
      return 1
    fi
    echo $command
    return 0
  }

  ######################
  ### Brew
  ######################

  local FB_FORMULA_PREVIEW='HOMEBREW_COLOR=true brew info {}'
  local FB_FORMULA_BIND="ctrl-space:execute-silent(brew home {})"
  local FB_CASK_PREVIEW='HOMEBREW_COLOR=true brew info --cask {}'
  local FB_CASK_BIND="ctrl-space:execute-silent(brew home --cask {})"

  local fzf-brew-install-formula() {
    local inst=$(brew formulae | fzf --query="$1" --multi --preview $FB_FORMULA_PREVIEW --bind $FB_FORMULA_BIND --prompt="brew install > ")
    if [[ $inst ]]; then
        for prog in $(echo $inst); do; brew install $prog; done;
    fi
  }

  local fzf-brew-uninstall-formula() {
    local uninst=$(brew leaves | fzf --query="$1" --multi --preview $FB_FORMULA_PREVIEW --bind $FB_FORMULA_BIND --prompt="brew uninstall > ")
    if [[ $uninst ]]; then
        for prog in $(echo $uninst); do; brew uninstall $prog; done;
    fi
  }

  local fzf-brew-install-cask() {
    local inst=$(brew casks | fzf --query="$1" --multi --preview $FB_CASK_PREVIEW --bind $FB_CASK_BIND --prompt="brew install --cask > ")
    if [[ $inst ]]; then
        for prog in $(echo $inst); do; brew install --cask $prog; done;
    fi
  }

  local fzf-brew-uninstall-cask() {
    local inst=$(brew list --cask | fzf --query="$1" --multi --preview $FB_CASK_PREVIEW --bind $FB_CASK_BIND --prompt="brew uninstall --cask > ")
    if [[ $inst ]]; then
        for prog in $(echo $inst); do; brew uninstall --cask $prog; done;
    fi
  }

  local fzf-brew-upgrade() {
    brew update --quiet
    local res=$(brew outdated --formula | fzf --query="$1" --multi --preview $FB_FORMULA_PREVIEW --bind $FB_FORMULA_BIND --prompt="brew upgrade > ")
    if [[ $res ]]; then
        for prog in $(echo $res); do; brew upgrade $prog; done;
    fi
  }

  local fzf-brew-upgrade-cask() {
    brew update --quiet
    local inst=$(brew outdated --cask | fzf --query="$1" --multi --preview $FB_CASK_PREVIEW --bind $FB_CASK_BIND --prompt="brew upgrade --cask > ")
    if [[ $inst ]]; then
        for prog in $(echo $inst); do; brew upgrade --cask $prog; done;
    fi
  }

  ######################
  ### Entry Point
  ######################

  local init() {
    local option_list=(
      "$(tput bold)install:$(tput sgr0)          Install a formula."
      "$(tput bold)uninstall:$(tput sgr0)        Uninstall a formula."
      " "
      "$(tput bold)install cask:$(tput sgr0)     Install a cask."
      "$(tput bold)uninstall cask:$(tput sgr0)   Uninstall a cask."
      " "
      "$(tput bold)upgrade:$(tput sgr0)          Upgrade a formula."
      "$(tput bold)upgrade all:$(tput sgr0)      Upgrade all formulae."
      " "
      "$(tput bold)upgrade cask:$(tput sgr0)     Upgrade a cask."
      "$(tput bold)upgrade all cask:$(tput sgr0) Upgrade all casks."
      " "
      "$(tput bold)list:$(tput sgr0)            List installed formulae and casks."
    )
    command=$(__parse_options "brew" ${option_list[@]})
    if [ $? -eq 1 ]; then
        zle accept-line
        zle -R -c
        return 1
    fi
    case "$command" in
      "install") fzf-brew-install-formula;;
      "uninstall") fzf-brew-uninstall-formula;;
      "install cask") fzf-brew-install-cask;;
      "uninstall cask") fzf-brew-uninstall-cask;;
      "upgrade") fzf-brew-upgrade;;
      "upgrade all") brew update --quiet && brew outdated && brew upgrade && brew cleanup;;
      "upgrade cask") fzf-brew-upgrade-cask;;
      "upgrade all cask") brew update --quiet && brew outdated --cask && brew upgrade --cask --greedy && brew cleanup;;
      *) echo "Error: Unknown command '$command'" ;;
    esac

    zle accept-line
    zle -R -c
  }

  init
}

zle -N fzf-brew
bindkey "${FZF_BREW_KEY_BINDING}" fzf-brew