#!/usr/bin/env bash

config="$(ovm_config_file)"

if [[ ! -f "$config" ]] || ! grep -Fqx -- "$OVM_CURSOR_BEGIN" "$config"; then
  printf 'Software cursor rendering is not installed; nothing to revert.\n'
  exit 0
fi

if ! grep -Fqx -- "$OVM_CURSOR_END" "$config"; then
  printf 'Refusing to modify an incomplete omarchy-vmware cursor section in %s\n' "$config" >&2
  exit 1
fi

tmp="$(mktemp "${config}.omarchy-vmware-cursor.XXXXXX")"
trap 'rm -f -- "$tmp"' EXIT
awk -v begin="$OVM_CURSOR_BEGIN" -v end="$OVM_CURSOR_END" '
  $0 == begin { managed=1; next }
  managed && $0 == end { managed=0; next }
  !managed { lines[++count]=$0 }
  END {
    while (count > 0 && lines[count] == "") count--
    for (i=1; i<=count; i++) print lines[i]
  }
' "$config" >"$tmp"
chmod --reference="$config" "$tmp"
mv -- "$tmp" "$config"
trap - EXIT

printf 'Removed the omarchy-vmware cursor setting from %s\n' "$config"
ovm_reload_hyprland || true
