#!/usr/bin/env bash

ovm_virtualization() {
  local detected=''
  if command -v systemd-detect-virt >/dev/null 2>&1; then
    detected="$(systemd-detect-virt 2>/dev/null || true)"
  fi
  case "${detected,,}" in
    vmware) printf 'VMware\n' ;;
    '') printf 'Unknown\n' ;;
    *) printf '%s\n' "$detected" ;;
  esac
}

ovm_is_vmware() {
  [[ "$(ovm_virtualization)" == 'VMware' ]] ||
    grep -Eqi 'vmware' /sys/class/dmi/id/{sys_vendor,product_name} 2>/dev/null
}

ovm_gpu() {
  local gpu=''
  if command -v lspci >/dev/null 2>&1; then
    gpu="$(lspci 2>/dev/null | awk 'BEGIN{IGNORECASE=1} /VGA compatible controller|3D controller/ {sub(/^.*: /, ""); print; exit}')"
  fi
  printf '%s\n' "${gpu:-Unknown}"
}

ovm_vmwgfx_state() {
  if [[ -d /sys/module/vmwgfx ]]; then
    printf 'vmwgfx (loaded)\n'
  elif command -v lspci >/dev/null 2>&1 && lspci -k 2>/dev/null | grep -q 'Kernel driver in use: vmwgfx'; then
    printf 'vmwgfx (in use)\n'
  else
    printf 'not detected\n'
  fi
}

ovm_hyprland_state() {
  if command -v hyprctl >/dev/null 2>&1 && hyprctl instances -j 2>/dev/null | grep -q 'instance'; then
    printf 'Hyprland (running)\n'
  elif command -v Hyprland >/dev/null 2>&1 || command -v hyprctl >/dev/null 2>&1; then
    printf 'Hyprland (installed, not running)\n'
  else
    printf 'not detected\n'
  fi
}

ovm_has_omarchy() {
  command -v omarchy >/dev/null 2>&1 || [[ -d /usr/share/omarchy ]]
}

ovm_recent_desktop_errors() {
  command -v journalctl >/dev/null 2>&1 || return 1
  journalctl --user -b --no-pager 2>/dev/null |
    grep -Eim1 'Wayland connection experienced a fatal error|Omarchy shell exited with status|Giving up on the Omarchy shell|failed to create dri2 screen|Hyprland has crashed|VMware: No 3D enabled'
}
