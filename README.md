# omarchy-vmware

This tool helps fix some graphics problems when running Omarchy in VMware. It
can help with a blank desktop, a missing top bar, an invisible mouse pointer,
broken theme previews, and LibreOffice display problems.

> **Tip:** VMware is not an ideal environment for Omarchy. Omarchy works best
> on a real computer with supported graphics hardware. These fixes may make a
> VMware installation more usable, but they cannot fix every graphics problem.

## Install from a local copy

Open a terminal in this project folder and run:

```bash
./install.sh
```

The installer does not use `sudo` and does not turn on any fix automatically.

## Use

First, check your system:

```bash
omarchy-vmware doctor
```

Turn the main desktop fix on or off:

```bash
omarchy-vmware apply
omarchy-vmware status
omarchy-vmware revert
```

Fix a missing top bar:

```bash
omarchy-vmware bar apply
omarchy-vmware bar status
omarchy-vmware bar revert
```

Fix an invisible mouse pointer:

```bash
omarchy-vmware cursor apply
omarchy-vmware cursor status
omarchy-vmware cursor revert
```

Fix broken theme previews:

```bash
omarchy-vmware preview apply
omarchy-vmware preview status
omarchy-vmware preview revert
```

Fix LibreOffice display problems:

```bash
omarchy-vmware libreoffice apply
omarchy-vmware libreoffice status
omarchy-vmware libreoffice revert
```

For each fix:

- `apply` turns it on.
- `status` shows whether it is on.
- `revert` turns it off.

The tool only changes settings that it manages. It does not change files in
`/usr/share/omarchy`, and it will not apply the main fix outside VMware.

## Open VM Tools

Open VM Tools is optional. To install it, run:

```bash
./scripts/install-open-vm-tools.sh
```

Run this command in a normal terminal. It installs system packages and starts
services, so it may ask for your `sudo` password. The script will not run
outside VMware.

## Limits

This project has only been tested in one VMware setup. It focuses on a small
set of display problems and does not include clipboard or screen-resolution
fixes. Results may be different on your system.
