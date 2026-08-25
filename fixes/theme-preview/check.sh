#!/usr/bin/env bash

if ovm_has_preview_fix; then
  printf 'Theme preview compatible rendering : enabled\n'
elif ovm_has_fix; then
  printf 'Theme preview compatible rendering : not installed (Qt software backend is active)\n'
else
  printf 'Theme preview compatible rendering : not installed\n'
fi
