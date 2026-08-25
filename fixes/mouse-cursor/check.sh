#!/usr/bin/env bash

if ovm_has_cursor_fix; then
  printf 'Software cursor rendering : enabled\n'
else
  printf 'Software cursor rendering : not installed\n'
fi
