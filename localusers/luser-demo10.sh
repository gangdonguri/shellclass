#!/bin/bash

log() {
  # This function sends a message to syslog and th standard output if VERBOST is true.
  local MESSAGE="${@}"
  if [[ "${VERBOSE}" = 'true' ]]
  then
    echo "${MESSAGE}"
  fi
  logger -t luser-demo10.sh "${MESSAGE}"
}

#function log {
#  echo 'You called the log functio!'
#} 

backup_file() {
  # This function creates a backup of a file. Returns non-zero status on error.
  
  local FILE="${1}"

  # Make sure the file exits.
  if [[ -f "${FILE}" ]]
  then
    local BACKUP_FILE="/var/tmp/$(basename ${FILE}).$(date +%F-%N)"
    log "Backing up ${FILE} to ${BACKUP_FILE}."

    # The exit status of the function will be the exit status of the cp command.
    cp -p ${FILE} ${BACKUP_FILE}
  else
    # The file does not exist, so return a non-zero exit status.
    return 1
  fi
}

readonly VERBOSE='true'
log 'Hello!'
log 'This is fun!'

backup_file '/etc/passwd'

# Make a decision based on the exit status of the function.
if [[ "${?}" -eq '0' ]]
then
  log 'File backup succeeded!'
else
  log 'File backup failed!'
  exit 1 # exit != return, 두 가지 모두 종료 상태를 의미하나, exit은 전체 스크립트를 종료합니다.
fi
