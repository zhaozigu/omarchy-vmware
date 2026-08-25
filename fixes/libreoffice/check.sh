#!/usr/bin/env bash

if ovm_has_libreoffice_fix; then
  printf 'LibreOffice native Wayland launch : enabled\n'
else
  printf 'LibreOffice native Wayland launch : not installed\n'
fi
