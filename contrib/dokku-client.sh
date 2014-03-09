#!/usr/bin/env bash

# This is a client script that will find the Dokku server for the working
# Git repository and then run any commands given to it on that server via SSH.
# To install, add it as an executable script in your local ~/bin directory
# under the name you want to call it as.

USERNAME=dokku

while true; do
    case $1 in
      --remote)
        shift
        REMOTE=$1
        shift
        ;;
      --remote=*)
        REMOTE=${1#--remote=}
        shift
        ;;
      --server)
        shift
        SERVER="$USERNAME@$1"
        shift
        ;;
      --server=*)
        SERVER="$USERNAME@${1#--server=}"
        shift
        ;;
      --)
        shift
        break
        ;;
      *)
        break
        ;;
    esac
done

if [ -z $SERVER ]; then
    REMOTE=${REMOTE:-dokku}
    REMOTE_URL=$(git config --get remote.$REMOTE.url)

    if [ $? -ne 0 ]; then
        echo "Remote \"$REMOTE\" not found"
        exit 1
    fi

    if [ ${REMOTE_URL%%@*} != $USERNAME ]; then
        echo "Remote \"$REMOTE\" does not appear to be a Dokku server"
        exit 1
    fi

    SERVER=${REMOTE_URL%%:*}
fi

ssh "$SERVER" "$@"
