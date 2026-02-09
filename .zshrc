# =================================================
# Load local zshrc (pre)
# =================================================
[ -f ~/.zshrc.local.pre ] && source ~/.zshrc.local.pre


# =================================================
# Setup managers and tools
# =================================================
# sheldon
eval "$(sheldon source)"

# Zellij
eval "$(zellij setup --generate-auto-start zsh)"

# Starship
eval "$(starship init zsh)"

# fzf
source <(fzf --zsh)

# mise
eval "$(~/.local/bin/mise activate zsh)"

# Emacs
[[ $EMACS = t ]] && unsetopt zle

# Rust
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# Haskell
[ -f "$HOME/.ghcup/env" ] && source "$HOME/.ghcup/env"


# =================================================
# History
# =================================================
HISTFILE="${ZDOTDIR:-$HOME}/.zhistory"
HISTSIZE=10000
SAVEHIST=10000

setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire a duplicate event first when trimming history.
setopt HIST_IGNORE_DUPS          # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete an old recorded event if a new event is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a previously found event.
setopt HIST_IGNORE_SPACE         # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file.
setopt HIST_VERIFY               # Do not execute immediately upon history expansion.
setopt HIST_BEEP                 # Beep when accessing non-existent history.


# =================================================
# Completion
# =================================================
autoload -Uz compinit && compinit


# =================================================
# aliases and functions
# =================================================
### Zsh ###
alias szrc='source ~/.zshrc'
alias szenv='source ~/.zshenv'
alias sz='szrc && szenv'

### Zellij ###
alias zj='zellij'

### Tools ###
alias clip='xclip -selection clipboard -in'
alias xmod='xmodmap ~/.Xmodmap'
alias wn='watch -n'
alias wn1='watch -n 1'
alias m='mise'
alias e='emacs -nw'
alias ew='emacs'

function fzf-tab() {
  functions[compadd]=$functions[-ftb-compadd]
  zle fzf-tab-complete
}
zle -N fzf-tab

function rename-session-to-current-directory() {
  rename-session $(basename $(pwd))
}
alias rs='rename-session-to-current-directory'

function guake-new-tab() {
  guake -n 0
}
zle -N guake-new-tab

ANSI_COLORS_RESET='\033[0m'
ANSI_COLORS_RED='\033[31m'
ANSI_COLORS_GREEN='\033[32m'
ANSI_COLORS_YELLOW='\033[33m'

function echo-info() {
  echo -e "${ANSI_COLORS_GREEN}[INFO] $1${ANSI_COLORS_RESET}"
}

function echo-warn() {
  echo -e "${ANSI_COLORS_YELLOW}[WARN] $1${ANSI_COLORS_RESET}"
}

function echo-error() {
  echo -e "${ANSI_COLORS_RED}[ERROR] $1${ANSI_COLORS_RESET}" >&2
}

function to-lower() {
  echo -n $@ | tr "[:upper:]" "[:lower:]"
}

function to-upper() {
  echo -n $@ | tr "[:lower:]" "[:upper:]"
}

function to-snake() {
  echo -n $@ | sed -E 's/(.)([A-Z])/\1_\2/g' | tr '[A-Z]' '[a-z]'
}

function to-pascal() {
  echo -n $@ | awk -F '_' '{ for (i = 1; i <= NF; i++) { printf toupper(substr($i, 1, 1)) substr($i, 2) } }'
}

function gen-random() {
  local length=${1:-16}
  local charset=${2:-'[:alnum:]'}

  more /dev/urandom | tr -d -c "$charset" | fold -w "$length" | head -n 1
}

function gen-random-graph() {
  gen-random ${1:-16} '[:graph:]'
}

function gen-random-alnum() {
  gen-random ${1:-16} '[:alnum:]'
}

function gen-random-url-safe() {
  gen-random ${1:-16} 'A-Za-z0-9_-'
}

function purl() {
  watch -n "$1" curl -m "$2" -i "$3"
}

### Files ###
alias ls='eza'
alias ll='ls -lhF'
alias la='ls -lahF'

function trash() {
  if [[ "$1" == "--empty" ]]; then
    empty-trash
    return
  fi

  for file in "$@"; do
    basename=$(basename "$file")
    abs_path=$(realpath "$file")
    echo "Trash '$abs_path'"
    mv -f "$file" "$TRASH/files/"

  info_file="$TRASH/info/${basename}.trashinfo"
  [ -e "$info_file" ] && rm -f "$info_file"
  cat <<END > "$info_file"
[Trash Info]
Path=$abs_path
DeletionDate=$(date +%Y-%m-%dT%H:%M:%S)
END
  done
}

function empty-trash() {
  echo -n "Empty trash? [y/N]: "
  read answer

  if [[ "$answer" =~ ^[Yy]$ ]]; then
    rm -rf "$TRASH/files/*"
    rm -rf "$TRASH/info/*"
  else
    echo "Cancelled."
  fi
}

function count-lines() {
  cat $@ | wc -l
}
alias cl='count-lines'

alias targz='tar cvzf'
alias untargz='tar xvzf'

alias pwdb='basename $(pwd)'

function clip-pwdb() {
  local name=$(pwdb)
  echo "Copy [$name] to clipboard!"
  echo -n "$name" | clip
}
alias cpwdb='clip-pwdb'

### Development ###
alias g='git'
alias gh-url='gh repo view --json "url" --jq ".url"'

alias t='task'

alias z='zed .'
alias zed-config='zed ~/.config/zed'

function code-open-workspace-or-directory() {
  if [ "$#" -eq 1 ]; then
      target_dir="$1"
  else
      target_dir="$PWD"
  fi

  local workspace="$(basename "$target_dir").code-workspace"

  if [ -f "$target_dir/$workspace" ]; then
      echo "Open workspace: $workspace in $target_dir"
      code "$target_dir/$workspace"
  else
      echo "Open directory: $target_dir"
      code "$target_dir"
  fi
}

alias c='code-open-workspace-or-directory'

function _cd-dev-find-repos() {
  local root_dir="$1"
  local maxdepth="$2"

  find "$root_dir" -maxdepth 3 -type d -name .git -exec dirname {} \; 2>/dev/null | \
    sed "s|$root_dir/||" | \
    sort
}

function _cd-dev-select-repo() {
  local root_dir="$1"

  fzf \
    --preview "tree -C $root_dir/{} -L 2 2>/dev/null | head -20 || ls -la $root_dir/{}" \
    --preview-window=right:50%:wrap \
    --height 40% \
    --layout=reverse \
    --border \
    --ansi \
    --prompt="Select repository: "
}

function cd-dev() {
  local root_dir="$HOME/develop"
  local repos=$(_cd-dev-find-repos "$root_dir")
  local selected_dir=$(echo "$repos" | _cd-dev-select-repo "$root_dir")

  if [[ -z "$selected_dir" ]]; then
    echo-info "No directory selected"
    return 0
  fi

  local target_path="$root_dir/$selected_dir"

  if [[ ! -d "$target_path" ]]; then
    echo-error "Selected directory does not exist: $target_path"
    return 1
  fi

  cd "$target_path"
  echo-info "Changed to: $target_path"

  rename-session-to-current-directory
}

alias cdd='cd-dev'

### AWS ###
function awv() {
  profile="default"
  verbose=false
  args=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --profile)
        profile="$2"
        shift 2
        ;;
      -v|--verbose)
        verbose=true
        shift
        ;;
      *)
        args+=("$1")
        shift
        ;;
    esac
  done

  if [[ "$verbose" == true ]]; then
    echo-info "Profile: $profile"
    echo-info "Command: aws ${args[@]}"
  fi

  aws-vault exec "$profile" -- aws "${args[@]}"
}

function aws-start-proxy() {
  region=us-east-1

  aws ec2 start-instances --region $region --instance-ids $@ &&
    aws ec2 wait instance-status-ok --region $region --instance-ids $@ &&
    aws ec2 describe-instances --region $region --instance-ids $@
}

function aws-stop-proxy() {
  region=us-east-1

  aws ec2 stop-instances --region $region --instance-ids $@ &&
    aws ec2 describe-instances --region $region --instance-ids $@
}

function aws-connect-instance () {
  instance_id=$1
  profile=$2

  aws ec2 start-instances --instance-ids $instance_id --profile $profile

  echo 'waiting...'
  aws ec2 wait instance-status-ok --instance-ids $instance_id --profile $profile

  aws ssm start-session --target $instance_id --profile $profile
}

### Docker ###
alias dokcer='docker'
alias docker-compose='docker compose'

alias dps='docker ps -a'
alias dmg='docker images'

function docker-rm-all() {
  docker rm $(docker ps -a -q)
}

function docker-rmi-all() {
  docker rmi $(docker images -q)
}

### AI Agents ###
function with-ask() {
  cmd="$1"
  shift
  args="$@"

  echo "[$cmd] Continue previous session? [Y/n]"
  read "answer?> "

  if [[ ${answer:l} =~ ^(n|no)$ ]]; then
    echo "==== Start new session ===="
    eval "$cmd"
  else
    eval "$cmd $args"
  fi
}

alias cll='claude-launcher'

alias ccv='claude-code-viewer'
alias ccv23='claude-code-viewer --claude-dir ~/.claude-23prime --port 3041'
alias ccvwk='claude-code-viewer --claude-dir ~/.claude-work --port 3042'

alias codex-ask='with-ask codex resume --last'
alias coa='codex-ask'

alias copilot='copilot --banner'
alias cpl='copilot'
alias copilot-ask='with-ask copilot --continue'
alias cpa='copilot-ask'

### GitHub CLI auto-switch ###
# Define mapping: git user.name -> gh account
typeset -A GH_ACCOUNT_MAP
GH_ACCOUNT_MAP=(
  # Example: "Your Git Name" "gh-account-name"
  "23prime" "23prime"
  "t_hikawa" "t-hikawa-satt"
)

function gh-auto-auth-switch() {
  # Check if we're in a git repository
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    return 0
  fi

  # Get git user.name
  local git_user=$(git config user.name 2>/dev/null)
  if [[ -z "$git_user" ]]; then
    return 0
  fi

  # Get corresponding GitHub account
  local gh_account="${GH_ACCOUNT_MAP[$git_user]}"
  if [[ -z "$gh_account" ]]; then
    return 0
  fi

  # Get current active account
  local current_account=$(gh auth status 2>&1 | grep "Active account: true" -B 3 | grep "Logged in to" | awk '{print $6}')

  # Switch only if different
  if [[ "$current_account" != "$gh_account" ]]; then
    gh auth switch -u "$gh_account" &>/dev/null
    if [[ $? -eq 0 ]]; then
      echo-info "Switched GitHub account to: $gh_account (git user: $git_user)"
    fi
  fi
}

# Add to chpwd hook
autoload -Uz add-zsh-hook
add-zsh-hook chpwd gh-auto-auth-switch


# AikidoSec Safe-chain Zsh initialization script
source ~/.safe-chain/scripts/init-posix.sh


# =================================================
# key bindings #
# =================================================
bindkey '^L' forward-char
bindkey '^H' backward-char
bindkey '^K' kill-line
bindkey '^Y' kill-line
bindkey '^V' yank
bindkey '^B' backward-delete-char
bindkey "^I" fzf-tab
bindkey '^T' guake-new-tab


# =================================================
# Load local zshrc (post)
# =================================================
[ -f ~/.zshrc.local.post ] && source ~/.zshrc.local.post
