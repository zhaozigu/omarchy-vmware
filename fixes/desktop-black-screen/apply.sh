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

if ovm_has_fix; then
  printf 'Qt Quick software rendering is already enabled.\n'
  printf 'Recommended: restart the virtual machine to ensure the fix takes full effect.\n'
  exit 0
fi

if grep -Fqx -- "$OVM_BEGIN" "$config" || grep -Fqx -- "$OVM_END" "$config"; then
  printf 'Refusing to modify an incomplete omarchy-vmware managed section in %s\n' "$config" >&2
  exit 1
fi

backup="${config}.omarchy-vmware.bak.$(date +%Y%m%d%H%M%S)"
cp -p -- "$config" "$backup"
{
  printf '\n%s\n' "$OVM_BEGIN"
  printf '%s\n' "$OVM_SETTING"
  printf '%s\n' "$OVM_END"
} >>"$config"

printf 'Enabled Qt Quick software rendering in %s\n' "$config"
printf 'Backup: %s\n' "$backup"
if ovm_reload_hyprland; then
  # A failed shell gives up after repeated crashes. Reloading Hyprland applies
  # the environment to future children, but does not relaunch that shell.
  ovm_restart_shell || true
fi

printf 'Recommended: restart the virtual machine to ensure the fix takes full effect.\n'
