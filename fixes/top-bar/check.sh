#!/usr/bin/env bash

if ovm_bar_is_hidden; then
  printf 'Omarchy top bar : hidden\n'
elif pgrep -x quickshell >/dev/null 2>&1; then
  printf 'Omarchy top bar : enabled (shell running)\n'
else
  printf 'Omarchy top bar : enabled (shell not running)\n'
fi
