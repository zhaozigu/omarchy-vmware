#!/usr/bin/env bash

config="$(ovm_config_file)"
if ! ovm_is_vmware; then
  printf 'Refusing to apply: VMware virtualization was not detected.\n' >&2
  exit 1
fi
if [[ ! -f "$config" ]]; then
  printf 'Hyprland user configuration not found: %s\n' "$config" >&2
  exit 1
fi
if ovm_has_preview_fix; then
  printf 'Theme preview compatible rendering is already enabled.\n'
  exit 0
fi
if ! grep -Fqx -- "$OVM_BEGIN" "$config" || ! grep -Fqx -- "$OVM_END" "$config"; then
  printf 'Apply the desktop rendering fix first: omarchy-vmware apply\n' >&2
  exit 1
fi
if ! grep -Fqx -- "$OVM_SETTING" "$config"; then
  printf 'Refusing to modify an unrecognized omarchy-vmware managed section in %s\n' "$config" >&2
  exit 1
fi

backup="${config}.omarchy-vmware-preview.bak.$(date +%Y%m%d%H%M%S)"
cp -p -- "$config" "$backup"
tmp="$(mktemp "${config}.omarchy-vmware-preview.XXXXXX")"
trap 'rm -f -- "$tmp"' EXIT
awk -v old="$OVM_SETTING" -v one="$OVM_PREVIEW_SETTING_1" \
  -v two="$OVM_PREVIEW_SETTING_2" -v three="$OVM_PREVIEW_SETTING_3" '
  $0 == old { print one; print two; print three; next }
  { print }
' "$config" >"$tmp"
chmod --reference="$config" "$tmp"
mv -- "$tmp" "$config"
trap - EXIT

printf 'Enabled theme preview compatible software OpenGL rendering in %s\n' "$config"
printf 'Backup: %s\n' "$backup"
ovm_reload_hyprland || true
if command -v omarchy >/dev/null 2>&1; then
  omarchy restart shell
else
  printf 'Restart the Omarchy shell to activate the change.\n'
fi
