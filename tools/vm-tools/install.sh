#!/usr/bin/env bash

if ! ovm_is_vmware; then
  printf 'Refusing to install: VMware virtualization was not detected.\n' >&2
  exit 1
fi

if ! command -v omarchy >/dev/null 2>&1; then
  printf 'Omarchy is required to install open-vm-tools.\n' >&2
  exit 1
fi

if ! command -v pacman >/dev/null 2>&1; then
  printf 'The pacman package manager is required to install open-vm-tools.\n' >&2
  exit 1
fi

if ovm_vm_tools_ready; then
  printf '[✓] Open VM Tools is already installed, enabled, and running; skipping.\n'
else
  if pacman -Q open-vm-tools >/dev/null 2>&1; then
    printf 'Open VM Tools is installed, but its services are not fully enabled or running.\n'
  else
    if ! pacman -Si open-vm-tools >/dev/null 2>&1; then
      cat >&2 <<'EOF'
Open VM Tools is not available in your current package database.

Update Omarchy first:
  omarchy update

After the update finishes, retry:
  omarchy-vmware vm-tools install
EOF
      exit 1
    fi

    printf 'Installing open-vm-tools...\n'
    omarchy pkg add open-vm-tools
  fi

  for unit in vmtoolsd.service vmware-vmblock-fuse.service; do
    if ! systemctl list-unit-files --no-legend "$unit" 2>/dev/null | grep -Fq "$unit"; then
      printf 'Expected service is missing after installation: %s\n' "$unit" >&2
      exit 1
    fi
  done

  printf 'Enabling and starting VMware Tools services...\n'
  ovm_run_as_root systemctl enable --now vmtoolsd.service vmware-vmblock-fuse.service

  for unit in vmtoolsd.service vmware-vmblock-fuse.service; do
    if systemctl is-enabled --quiet "$unit" && systemctl is-active --quiet "$unit"; then
      printf '  [✓] %s is enabled and active\n' "$unit"
    else
      printf '  [!] %s is not enabled and active after setup\n' "$unit" >&2
      ovm_run_as_root systemctl status --no-pager "$unit" >&2 || true
      exit 1
    fi
  done

  printf 'Open VM Tools installation complete.\n'
fi
