#!/bin/bash

#run a set of command and log the result(redirecting stdout, stdin, stdin)
#run code
exec >> log/hook-out.log 2>&1

if git diff-tree --name-only --no-commit-id ORIG_HEAD HEAD | grep --quiet 'package.json'; then
  echo "$(date): Running npm install because package.json changed"
  npm install > /dev/null
else
  echo "$(date): No changes in the package.json found"
fi