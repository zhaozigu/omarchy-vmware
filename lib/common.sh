#!/usr/bin/env bash

set -o pipefail

readonly OVM_BEGIN='-- BEGIN omarchy-vmware'
readonly OVM_END='-- END omarchy-vmware'
readonly OVM_SETTING='hl.env("QT_QUICK_BACKEND", "software")'
readonly OVM_PREVIEW_SETTING_1='hl.env("QT_QUICK_BACKEND", "rhi")'
readonly OVM_PREVIEW_SETTING_2='hl.env("QSG_RHI_BACKEND", "opengl")'
readonly OVM_PREVIEW_SETTING_3='hl.env("LIBGL_ALWAYS_SOFTWARE", "1")'
readonly OVM_CURSOR_BEGIN='-- BEGIN omarchy-vmware cursor'
readonly OVM_CURSOR_END='-- END omarchy-vmware cursor'
readonly OVM_CURSOR_SETTING='hl.config({ cursor = { no_hardware_cursors = 1, invisible = false } })'
readonly OVM_LIBREOFFICE_MARKER='X-Omarchy-VMware-LibreOffice-Wayland=true'

ovm_bar_toggle_file() {
  printf '%s/omarchy/toggles/bar-off\n' "${XDG_STATE_HOME:-$HOME/.local/state}"
}

ovm_bar_is_hidden() {
  [[ -f "$(ovm_bar_toggle_file)" ]]
}

ovm_config_file() {
  printf '%s\n' "${OMARCHY_VMWARE_HYPRLAND_CONFIG:-${XDG_CONFIG_HOME:-$HOME/.config}/hypr/hyprland.lua}"
}

ovm_has_fix() {
  local config
  config="$(ovm_config_file)"
  [[ -f "$config" ]] && grep -Fqx -- "$OVM_BEGIN" "$config" &&
    (grep -Fqx -- "$OVM_SETTING" "$config" || ovm_has_preview_fix) &&
    grep -Fqx -- "$OVM_END" "$config"
}

ovm_has_preview_fix() {
  local config
  config="$(ovm_config_file)"
  [[ -f "$config" ]] && grep -Fqx -- "$OVM_BEGIN" "$config" &&
    grep -Fqx -- "$OVM_PREVIEW_SETTING_1" "$config" &&
    grep -Fqx -- "$OVM_PREVIEW_SETTING_2" "$config" &&
    grep -Fqx -- "$OVM_PREVIEW_SETTING_3" "$config" &&
    grep -Fqx -- "$OVM_END" "$config"
}

ovm_has_cursor_fix() {
  local config
  config="$(ovm_config_file)"
  [[ -f "$config" ]] && grep -Fqx -- "$OVM_CURSOR_BEGIN" "$config" &&
    grep -Fqx -- "$OVM_CURSOR_SETTING" "$config" && grep -Fqx -- "$OVM_CURSOR_END" "$config"
}

ovm_libreoffice_app_dir() {
  printf '%s/applications\n' "${XDG_DATA_HOME:-$HOME/.local/share}"
}

ovm_has_libreoffice_fix() {
  local app_dir file found=0
  app_dir="$(ovm_libreoffice_app_dir)"
  for file in /usr/share/applications/libreoffice*.desktop; do
    [[ -f "$file" ]] || continue
    found=1
    [[ -f "$app_dir/${file##*/}" ]] || return 1
    grep -Fqx -- "$OVM_LIBREOFFICE_MARKER" "$app_dir/${file##*/}" || return 1
  done
  (( found == 1 ))
}

ovm_reload_hyprland() {
  local signature=''
  if command -v hyprctl >/dev/null 2>&1; then
    signature="$(hyprctl instances -j 2>/dev/null |
      sed -n 's/.*"instance": "\([^"]*\)".*/\1/p' | head -1)"
  fi

  if [[ -n "$signature" ]]; then
    if HYPRLAND_INSTANCE_SIGNATURE="$signature" hyprctl reload >/dev/null &&
      HYPRLAND_INSTANCE_SIGNATURE="$signature" hyprctl configerrors 2>/dev/null; then
      printf 'Hyprland reloaded successfully.\n'
      return 0
    fi
    printf 'Warning: Hyprland reload or validation failed; inspect: hyprctl configerrors\n' >&2
    return 1
  fi

  printf 'Hyprland is not running; log out and back in to activate the change.\n'
}

ovm_restart_shell() {
  if ! command -v omarchy >/dev/null 2>&1; then
    printf 'Omarchy is not installed; log out and back in to restart the desktop shell.\n'
    return 0
  fi

  if ! command -v hyprctl >/dev/null 2>&1 ||
    ! hyprctl instances -j 2>/dev/null | grep -q '"instance"'; then
    printf 'Hyprland is not running; log out and back in to restart the desktop shell.\n'
    return 0
  fi

  if omarchy restart shell; then
    printf 'Omarchy shell restarted successfully.\n'
    return 0
  fi

  printf 'Warning: Omarchy shell did not restart; try: omarchy restart shell\n' >&2
  return 1
}
