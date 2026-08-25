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

if ovm_has_cursor_fix; then
  printf 'Software cursor rendering is already enabled.\n'
  exit 0
fi

if grep -Fqx -- "$OVM_CURSOR_BEGIN" "$config" || grep -Fqx -- "$OVM_CURSOR_END" "$config"; then
  printf 'Refusing to modify an incomplete omarchy-vmware cursor section in %s\n' "$config" >&2
  exit 1
fi

backup="${config}.omarchy-vmware-cursor.bak.$(date +%Y%m%d%H%M%S)"
cp -p -- "$config" "$backup"
{
  printf '\n%s\n' "$OVM_CURSOR_BEGIN"
  printf '%s\n' "$OVM_CURSOR_SETTING"
  printf '%s\n' "$OVM_CURSOR_END"
} >>"$config"

printf 'Enabled software cursor rendering in %s\n' "$config"
printf 'Backup: %s\n' "$backup"
ovm_reload_hyprland || true
