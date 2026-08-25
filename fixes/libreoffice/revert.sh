#!/usr/bin/env bash

app_dir="$(ovm_libreoffice_app_dir)"
removed=0
for target_file in "$app_dir"/libreoffice*.desktop; do
  [[ -f "$target_file" ]] || continue
  grep -Fqx -- "$OVM_LIBREOFFICE_MARKER" "$target_file" || continue
  unlink -- "$target_file"
  removed=1
done

if (( removed == 0 )); then
  printf 'LibreOffice native Wayland launch is not installed; nothing to revert.\n'
  exit 0
fi
command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$app_dir" >/dev/null 2>&1 || true
printf 'Removed LibreOffice native Wayland desktop overrides from %s\n' "$app_dir"
