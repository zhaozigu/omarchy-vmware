#!/usr/bin/env bash

if ! command -v omarchy >/dev/null 2>&1; then
  printf 'Omarchy is not installed; cannot hide its top bar.\n' >&2
  exit 1
fi

if ovm_bar_is_hidden; then
  printf 'Omarchy top bar is already hidden.\n'
  exit 0
fi

# The Omarchy toggle is named "bar-off": enabling that flag hides the bar.
omarchy toggle bar on
printf 'Hid the Omarchy top bar.\n'
