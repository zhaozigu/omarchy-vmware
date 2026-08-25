#!/usr/bin/env bash

config="$(ovm_config_file)"
if ! ovm_has_preview_fix; then
  printf 'Theme preview compatible rendering is not installed; nothing to revert.\n'
  exit 0
fi

backup="${config}.omarchy-vmware-preview-revert.bak.$(date +%Y%m%d%H%M%S)"
cp -p -- "$config" "$backup"
tmp="$(mktemp "${config}.omarchy-vmware-preview.XXXXXX")"
trap 'rm -f -- "$tmp"' EXIT
awk -v one="$OVM_PREVIEW_SETTING_1" -v two="$OVM_PREVIEW_SETTING_2" \
  -v three="$OVM_PREVIEW_SETTING_3" -v old="$OVM_SETTING" '
  $0 == one { print old; next }
  $0 == two || $0 == three { next }
  { print }
' "$config" >"$tmp"
chmod --reference="$config" "$tmp"
mv -- "$tmp" "$config"
trap - EXIT

printf 'Restored the basic Qt Quick software renderer in %s\n' "$config"
printf 'Backup: %s\n' "$backup"
ovm_reload_hyprland || true
command -v omarchy >/dev/null 2>&1 && omarchy restart shell || true
