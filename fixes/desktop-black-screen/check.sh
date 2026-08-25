#!/usr/bin/env bash

if ovm_has_fix; then
  printf 'Qt Quick software rendering : enabled\n'
else
  printf 'Qt Quick software rendering : not installed\n'
fi
