#!/usr/bin/env bash

if ! ovm_is_vmware; then
  printf 'Refusing to apply: VMware virtualization was not detected.\n' >&2
  exit 1
fi
if ! command -v libreoffice >/dev/null 2>&1; then
  printf 'LibreOffice is not installed.\n' >&2
  exit 1
fi
if [[ ! -f /usr/lib/libreoffice/program/libvclplug_gtk3lo.so ]]; then
  printf 'LibreOffice GTK 3 support is not installed.\n' >&2
  exit 1
fi
if ovm_has_libreoffice_fix; then
  printf 'LibreOffice native Wayland launch is already enabled.\n'
  exit 0
fi

app_dir="$(ovm_libreoffice_app_dir)"
mkdir -p -- "$app_dir"
found=0
for source_file in /usr/share/applications/libreoffice*.desktop; do
  [[ -f "$source_file" ]] || continue
  found=1
  target_file="$app_dir/${source_file##*/}"
  if [[ -e "$target_file" ]] && ! grep -Fqx -- "$OVM_LIBREOFFICE_MARKER" "$target_file"; then
    printf 'Refusing to replace an existing user override: %s\n' "$target_file" >&2
    exit 1
  fi
done
(( found == 1 )) || { printf 'No LibreOffice desktop launchers were found.\n' >&2; exit 1; }

for source_file in /usr/share/applications/libreoffice*.desktop; do
  [[ -f "$source_file" ]] || continue
  target_file="$app_dir/${source_file##*/}"
  awk -v marker="$OVM_LIBREOFFICE_MARKER" '
    /^Exec=libreoffice([[:space:]]|$)/ {
      sub(/^Exec=libreoffice/, "Exec=env DISPLAY= GDK_BACKEND=wayland SAL_USE_VCLPLUGIN=gtk3 /usr/bin/libreoffice")
    }
    { print }
    END { print marker }
  ' "$source_file" >"$target_file"
done

command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$app_dir" >/dev/null 2>&1 || true
printf 'Enabled LibreOffice native Wayland launch in %s\n' "$app_dir"
