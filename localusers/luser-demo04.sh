#!/bin/bash

# This script creates an account on the local system.
# You will be prompted for the account name and password.

# Ask for the user name.
read -p 'Enter the username to create: ' USER_NAME

# Ask for the real name.
read -p 'Enter the name of the person who this account is for: ' COMMENT

# Ask for the password.
read -p 'Enter the password to use for the account: ' PASSWORD

# Create the user.
# COMMENT 변수를 곁따옴표로 묶은 이유는 입력 받은 COMMENT 변수에 공백이 포함될 수도 있기 때문입니다.
useradd -c "${COMMENT}" -m ${USER_NAME}

# Set the passwrod for the user.
echo ${PASSWORD} | passwd --stdin ${USER_NAME}

# Force password change on first login.
passwd -e ${USER_NAME}
