#!/bin/bash


usage() {
  # Display the usage and exit.
  echo "Usage: ${0} [-nsv] [-f FILE] COMMAND" >&2
  echo "Executes COMMAND as a single command on every server." >&2
  echo "  -f FILE  Use FILE for the list of servers. Default: /vagrant/servers" >&2
  echo "  -n       Dry run mode. Display the COMMAND that would have been executed and exit." >&2
  echo "  -s       Execute the COMMAND using sudo on the remote server." >&2
  echo "  -v       Verbose mode. Displays the server name before executing COMMAND." >&2
  exit 1
}

SERVER_FILE='/vagrant/servers'
SSH_OPTION='ConnectTimeout=2'

# Make sure the script is not being executed with superuser privileges.
if [[ "${UID}" -eq 0 ]]
then
  echo 'Do not execute this script as root.  Use the -s option instead.' >&2
  usage
  exit 1
fi

# Parse the options.
while getopts nsvf: OPTION
do
  case ${OPTION} in
    n) DRY_RUN_MODE='true' ;;
    s) PRIVILEGES='sudo' ;;
    v) VERBOSE_MODE='true' ;;
    f) SERVER_FILE="${OPTARG}" ;;
    ?) usage ;;
  esac
done

# Remove the options while leaving the remaining arguments.
shift "$(( OPTIND - 1 ))"

# If the user dosen't supply at least one argument, give them help.
if [[ "${#}" -lt 1 ]]
then
  usage
fi

# Anything that remains on the command line is to be treated as a single command.
COMMAND="${@}"

# Make sure the SERVER_LIST file exists.
if [[ ! -e "${SERVER_FILE}" ]]
then
  echo "Cannot open server list file ${SERVER_FILE}" >&2
  exit 1
fi

# Loop through the SERVER_LIST
for SERVER in $(cat ${SERVER_FILE})
do
  # If it's dry run, don't execute anything, just echo it.
  if [[ "${DRY_RUN_MODE}" = 'true' ]]
  then
    echo "DRY RUN: ssh -o ${SSH_OPTION} ${SERVER} ${PRIVILEGES} ${COMMAND}"
  else
    if [[ "${VERBOSE_MODE}" = 'true' ]]
    then
      echo ${SERVER}
    fi
    ssh -o ${SSH_OPTION} ${SERVER} ${PRIVILEGES} ${COMMAND}
    STATUS="${?}"
    # Capture any non-zero exit status from the SSH_COMMAND and report to the user.
    if [[ "${STATUS}" -ne 0 ]]
    then
      echo "Execution on server ${SERVER} failed." >&2
      exit "${STATUS}"
    fi
  fi
done

exit 0
  
