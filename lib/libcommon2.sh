# common functions

# general return codes of functions
#
WARNING_DONE=2
ERROR_FILE_NOT_FOUND=80
ERROR_SYNTAX_ERROR=81


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

# execute function on remote host
# syntax:
#   remote_exec $hostname $additional_lib $env $func_name $func_params
#
remote_exec()
{
  local _host=${1}
  local _libfile=${2}
  local _env=${3}
  local _funcname=${4}
  local _params=""
  
  local _cmd="source ${DEPLOYER}/lib/remote.env ;"
  if [ ! "${_env}" == "noenv" ];
  then
    _cmd+=" ${_env};"
  fi
  _cmd+=" source ${DEPLOYER}/lib/${_libfile}.sh ;"
  _cmd+=" ${_funcname}"
  for p in ${@:5};
  do
    _cmd+=" ${p}"
  done

  # execute command on remote host
  #echo "ssh ${_host} -- ${_cmd}" 
  ssh ${_host} -- ${_cmd} 
}

