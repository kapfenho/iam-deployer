# common functions

# general return codes of functions
# 
WARNING_DONE=0
ERROR_FILE_NOT_FOUND=80
ERROR_SYNTAX_ERROR=81
ERROR_WLST=82

log() {
  if [[ -t 1 ]]; then
    printf "%b>>>%b %b%s%b\n" "\x1b[1m\x1b[32m" "\x1b[0m" \
                              "\x1b[1m\x1b[37m" "$1" "\x1b[0m"
  else
    printf ">>> %s\n" "$1"
  fi
}

error() {
  if [[ -t 1 ]]; then
    printf "%b!!!%b %b%s%b\n" "\x1b[1m\x1b[31m" "\x1b[0m" \
                              "\x1b[1m\x1b[37m" "$1" "\x1b[0m" >&2
  else
    printf "!!! %s\n" "$1" >&2
  fi
}

warning() {
  if [[ -t 1 ]]; then
    printf "%b***%b %b%s%b\n" "\x1b[1m\x1b[33m" "\x1b[0m" \
                        "\x1b[1m\x1b[37m" "$1" "\x1b[0m" >&2
  else
    printf "*** %s\n" "$1" >&2
  fi
}
