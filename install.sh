#!/usr/bin/env bash
set -euo pipefail

repo="${OMARCHY_VMWARE_REPO:-zhaozigu/omarchy-vmware}"
branch="${OMARCHY_VMWARE_BRANCH:-main}"
data_dir="${XDG_DATA_HOME:-$HOME/.local/share}/omarchy-vmware"
bin_dir="${HOME}/.local/bin"
source_dir=''
tmp_dir=''
script_source="${BASH_SOURCE[0]:-}"
script_dir=''

cleanup() { [[ -z "$tmp_dir" ]] || rm -rf -- "$tmp_dir"; }
trap cleanup EXIT

if [[ -n "$script_source" ]]; then
  script_dir="$(cd -- "$(dirname -- "$script_source")" 2>/dev/null && pwd || true)"
fi
if [[ -n "$script_dir" && -f "$script_dir/bin/omarchy-vmware" && -f "$script_dir/lib/common.sh" ]]; then
  source_dir="$script_dir"
else
  command -v curl >/dev/null 2>&1 || { printf 'curl is required.\n' >&2; exit 1; }
  tmp_dir="$(mktemp -d)"
  curl -fsSL "https://github.com/${repo}/archive/refs/heads/${branch}.tar.gz" |
    tar -xz -C "$tmp_dir" --strip-components=1
  source_dir="$tmp_dir"
fi

mkdir -p -- "$data_dir" "$bin_dir"
# Remove the legacy standalone script directory from earlier installations.
rm -rf -- "$data_dir/scripts"
for item in bin lib fixes tools LICENSE README.md; do
  rm -rf -- "$data_dir/$item"
  cp -R -- "$source_dir/$item" "$data_dir/$item"
done
chmod +x -- "$data_dir/bin/omarchy-vmware" "$data_dir/fixes/desktop-black-screen/"*.sh
chmod +x -- "$data_dir/fixes/mouse-cursor/"*.sh
chmod +x -- "$data_dir/fixes/theme-preview/"*.sh
chmod +x -- "$data_dir/fixes/libreoffice/"*.sh
chmod +x -- "$data_dir/fixes/top-bar/"*.sh
chmod +x -- "$data_dir/tools/vm-tools/install.sh"
ln -sfn -- "$data_dir/bin/omarchy-vmware" "$bin_dir/omarchy-vmware"

printf '\nomarchy-vmware was installed successfully.\n'
printf '  Location: %s\n' "$data_dir"
printf '  Command : %s/omarchy-vmware\n' "$bin_dir"
printf '\nNo Hyprland settings were changed automatically.\n'
printf '\nRecommended next steps:\n'
printf '  1. Check your VMware and Omarchy setup:\n'
printf '     omarchy-vmware doctor\n'
printf '  2. Apply the main desktop display fix:\n'
printf '     omarchy-vmware apply\n'
printf '\nOptional fixes (run only when needed):\n'
printf '  Missing top bar       : omarchy-vmware bar apply\n'
printf '  Invisible mouse cursor: omarchy-vmware cursor apply\n'
printf '  Broken theme previews : omarchy-vmware preview apply\n'
printf '  LibreOffice display   : omarchy-vmware libreoffice apply\n'
printf '  Install Open VM Tools : omarchy-vmware vm-tools install\n'
printf '\nRun omarchy-vmware --help to see all available commands.\n'
