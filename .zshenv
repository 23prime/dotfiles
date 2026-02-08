export TRASH=$HOME/.local/share/Trash/
export SPRING_PROFILES_ACTIVE=at-localpc

export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log

path=(
  $HOME/.local/bin(N-/)
  $HOME/.cargo/bin(N-/)
  $HOME/.local/scripts(N-/)
  $HOME/.local/share/mise/shims(N-/)

  /bin:$PATH(N-/)
  /opt(N-/)

  /usr/bin/sbin(N-/)
  /usr/local/bin(N-/)
  /usr/local/sbin(N-/)
  /usr/local/games(N-/)
  /usr/sbin(N-/)

  $path
)
