#!/usr/bin/env bash

if ! command -v omarchy >/dev/null 2>&1; then
  printf 'Omarchy is not installed; cannot enable its top bar.\n' >&2
  exit 1
fi

if ! ovm_bar_is_hidden; then
  printf 'Omarchy top bar is already enabled.\n'
  exit 0
fi

# The Omarchy toggle is named "bar-off": disabling that flag shows the bar.
omarchy toggle bar off
printf 'Enabled the Omarchy top bar.\n'
