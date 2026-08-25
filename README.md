# omarchy-vmware

This tool helps fix some graphics problems when running Omarchy in VMware. It
can help with a blank desktop, a missing top bar, an invisible mouse pointer,
broken theme previews, and LibreOffice display problems.

> **Tip:** VMware is not an ideal environment for Omarchy. Omarchy works best
> on a real computer with supported graphics hardware. These fixes may make a
> VMware installation more usable, but they cannot fix every graphics problem.

## Before You Start

Make sure 3D graphics acceleration is enabled for the virtual machine. In its
VMware settings, go to **Display** and check **Accelerate 3D graphics** if it
is not already enabled.

### If the desktop is blank

If the desktop is blank or you cannot open a graphical terminal, install and
run this tool from a Linux virtual console (TTY):

1. Click inside the VMware window and press **Ctrl+Alt+F3**. If no login prompt
   appears, try **Ctrl+Alt+F2** through **Ctrl+Alt+F6**. On some laptops you may
   also need to hold **Fn**. If VMware captures the shortcut, use its keyboard
   or send-key menu to send the same keys to the virtual machine.
2. Log in with your normal Omarchy user account, not `root`. Password characters
   are not displayed while you type; this is normal.
3. Install the latest version:

   ```bash
   curl -fsSL https://raw.githubusercontent.com/zhaozigu/omarchy-vmware/main/install.sh | bash
   ```

4. Check the system and run the complete repair. The full command path works
   even when the new TTY session has not added `~/.local/bin` to `PATH`:

   ```bash
   ~/.local/bin/omarchy-vmware doctor
   ~/.local/bin/omarchy-vmware fix --all
   ```

The complete repair restarts the virtual machine only when it makes a package
or repair change. If `curl` reports a network or DNS error, connect the virtual
machine to the network before retrying.

## Install

Install the latest version from GitHub:

```bash
curl -fsSL https://raw.githubusercontent.com/zhaozigu/omarchy-vmware/main/install.sh | bash
```

After installation, check your system:

```bash
omarchy-vmware doctor
```

The installer does not use `sudo` and does not turn on any fix automatically.

### Install from a local copy

Open a terminal in this project folder and run:

```bash
./install.sh
```

## Use

First, check your system:

```bash
omarchy-vmware doctor
```

Run the complete repair in one command:

```bash
omarchy-vmware fix --all
```

This checks the environment and current fixes, updates Omarchy and the system,
installs Open VM Tools, and applies every relevant missing fix. The system
restarts after all steps succeed only when a package or repair change was made;
if everything was already up to date, the restart is skipped. LibreOffice
integration is skipped when LibreOffice with GTK 3 support is not installed. If
any step fails, the command stops and does not restart the system.

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
omarchy-vmware vm-tools install
```

Run this command in a normal terminal. It installs system packages and starts
services, so it may ask for your `sudo` password. The command will not run
outside VMware. If `open-vm-tools` is not available in the current package
database, the command will ask you to run `omarchy update` first and show the
command to retry afterward.

## Limits

This project has only been tested in one VMware setup. It focuses on a small
set of display problems and does not include clipboard or screen-resolution
fixes. Results may be different on your system.
