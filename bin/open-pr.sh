#!/bin/bash

# create a github pull request using bash

# code
current_branch=$(git rev-parse --abbrev-ref HEAD)
username=''
password=''
title=''

usage() {
  echo "Usage: open-pr [-u <username>] [-p <password/token>] [-t <title of the pull request>] <body of the PR>"
}

while getopts ':u:p:t:h' opt; do
  case "$opt" in
    u)
      username="$OPTARG"
    ;;
    p)
      password="$OPTARG"
    ;;
    t)
      title="$OPTARG"
    ;;
    h)
      usage
      exit
    ;;
    \?)
      echo "Invalid option $OPTARG" >&2
      usage >&2
      exit 1
    ;;
  esac
done

shift $(( OPTIND - 1 ))

if [[ $current_branch == 'master' ]]; then
  echo "you are already on the master branch, create a new branch, push it and then run the script" >&2
  exit 1
fi

check_is_set() {
  if [[ -z $2 ]]; then
    echo "ERROR: $1 must be set" >&2
    usage >&2
    exit 1
  fi
}

check_is_set "username" $username
check_is_set "password" $password
check_is_set "title" $title

data=$(cat <<-END
{
  "title": "$title",
  "base": "master",
  "head": "$current_branch",
  "body": "$@"
}
END
)

status_code=$(curl -s --user "$username:$password" -X POST "https://api.github.com/repos/Oluwasetemi/sandbox/pulls" -d "$data" -w %{http_code} -o /dev/null)

if [[ $status_code == "201" ]]; then
  echo "completed"
else
  echo "error received, $status_code status received" >&2
  exit 1
fi