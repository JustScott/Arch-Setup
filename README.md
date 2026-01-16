Arch-Setup provides an easy to use `arch` CLI tool for installing and
configuring packages or entire system configurations in a single command.

## Instructions

The CLI tool `arch` can be installed to your system by running:
```bash
bash ./arch add-to-path
```
This replaces manually running the installation scripts for package installation
and setup of supported packages and system configurations.

### `arch` install
For installing specific packages that may require more setup than a single
pacman command

```bash
# You can now run
arch install docker

# Instead of 
bash docker.sh
```
You can list available packages with:
```bash
arch install --list
```
But the best feature of arch in my opinion, is the ability to cleanly remove
these packages from your system:
```bash
arch uninstall qemu
```

### `arch` setup
For setting up complex system configurations

For example, setting up your system for gaming takes quite a lot of 
configuration, but `arch` makes it as easy as
```bash
arch setup gaming
```
And to cleanly undo everything that sets up, just run:
```
arch remove-setup gaming
```

### Replaces the Arch-Configurations repo
The Arch-Configurations installation script and directories have been moved
into and updated to work with Arch-Setup.

The installation is now ran after nearly every `arch <command>` call, but it
can also be manually called:
```bash
arch add-configs
```
The script that `add-configs` calls is much smarter than what Arch-Configurations
had. It now only runs steps that haven't already been ran. So most of the time it
will have no output.

## Errors
* All error logs will be written to `/tmp/archsetuperrors.log` (which will be 
  deleted at reboot)
