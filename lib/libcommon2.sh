# common functions

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

do_idm() {
  local _ret
  case "${DO_IDM}" in
    YES|yes|1)
      _ret=0;;
    *)
      _ret=1;;
  esac
  return $_ret
}

do_acc() {
  local _ret
  case "${DO_ACC}" in
    YES|yes|1)
      _ret=0;;
    *)
      _ret=1;;
  esac
  return $_ret
}

do_bip() {
  local _ret
  case "${DO_BIP}" in
    YES|yes|1)
      _ret=0;;
    *)
      _ret=1;;
  esac
  return $_ret
}
