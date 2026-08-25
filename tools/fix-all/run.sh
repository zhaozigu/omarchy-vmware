#!/usr/bin/env bash

ovm_fix_all_config="$(ovm_config_file)"

if ! ovm_is_vmware; then
  printf 'Refusing to run the complete repair: VMware virtualization was not detected.\n' >&2
  exit 1
fi

if ! command -v omarchy >/dev/null 2>&1; then
  printf 'Omarchy is required to run the complete repair.\n' >&2
  exit 1
fi

if [[ ! -f "$ovm_fix_all_config" ]]; then
  printf 'Hyprland user configuration not found: %s\n' "$ovm_fix_all_config" >&2
  exit 1
fi

for ovm_fix_all_command in pacman systemctl; do
  if ! command -v "$ovm_fix_all_command" >/dev/null 2>&1; then
    printf 'Required command not found: %s\n' "$ovm_fix_all_command" >&2
    exit 1
  fi
done

if (( EUID != 0 )) && ! command -v sudo >/dev/null 2>&1; then
  printf 'sudo is required to install services and restart the system.\n' >&2
  exit 1
fi

printf 'Omarchy VMware complete repair\n'
printf 'The system will restart after all steps complete successfully.\n\n'
printf 'Detected repair plan\n'
ovm_vm_tools_ready && printf '  [✓] Open VM Tools already installed and running\n' || printf '  [ ] Install or activate Open VM Tools\n'
ovm_has_fix && printf '  [✓] Desktop rendering fix already enabled\n' || printf '  [ ] Enable desktop rendering fix\n'
ovm_has_cursor_fix && printf '  [✓] Software cursor already enabled\n' || printf '  [ ] Enable software cursor\n'
ovm_bar_is_hidden && printf '  [ ] Enable the Omarchy top bar\n' || printf '  [✓] Omarchy top bar already enabled\n'
ovm_has_preview_fix && printf '  [✓] Theme preview fix already enabled\n' || printf '  [ ] Enable theme preview fix\n'
if command -v libreoffice >/dev/null 2>&1 && [[ -f /usr/lib/libreoffice/program/libvclplug_gtk3lo.so ]]; then
  ovm_has_libreoffice_fix && printf '  [✓] LibreOffice fix already enabled\n' || printf '  [ ] Enable LibreOffice native Wayland support\n'
else
  printf '  [-] Skip LibreOffice fix (LibreOffice with GTK 3 support not detected)\n'
fi
printf '\n'

printf '[1/8] Updating Omarchy and system packages...\n'
omarchy update

printf '\n[2/8] Checking Open VM Tools...\n'
source "$project_root/tools/vm-tools/install.sh"

printf '\n[3/8] Checking desktop rendering...\n'
if ovm_has_fix; then
  printf 'Desktop rendering fix is already enabled; skipping.\n'
else
  source "$project_root/fixes/desktop-black-screen/apply.sh"
fi

printf '\n[4/8] Checking the mouse cursor...\n'
if ovm_has_cursor_fix; then
  printf 'Software cursor rendering is already enabled; skipping.\n'
else
  source "$project_root/fixes/mouse-cursor/apply.sh"
fi

printf '\n[5/8] Checking the Omarchy top bar...\n'
if ovm_bar_is_hidden; then
  source "$project_root/fixes/top-bar/apply.sh"
else
  printf 'Omarchy top bar is already enabled; skipping.\n'
fi

printf '\n[6/8] Checking theme previews...\n'
if ovm_has_preview_fix; then
  printf 'Theme preview compatible rendering is already enabled; skipping.\n'
else
  source "$project_root/fixes/theme-preview/apply.sh"
fi

printf '\n[7/8] Checking LibreOffice...\n'
if ! command -v libreoffice >/dev/null 2>&1; then
  printf 'LibreOffice is not installed; skipping.\n'
elif [[ ! -f /usr/lib/libreoffice/program/libvclplug_gtk3lo.so ]]; then
  printf 'LibreOffice GTK 3 support is not installed; skipping.\n'
elif ovm_has_libreoffice_fix; then
  printf 'LibreOffice native Wayland launch is already enabled; skipping.\n'
else
  source "$project_root/fixes/libreoffice/apply.sh"
fi

printf '\n[8/8] Complete repair finished successfully. Restarting the system...\n'
sync
ovm_run_as_root systemctl reboot
