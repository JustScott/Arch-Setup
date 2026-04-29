Arch-Setup provides an easy to use `please` CLI tool for installing and
configuring packages or entire system configurations in a single command.

## Instructions

The CLI tool `please` can be installed to your system by running:
```bash
bash ./please add-to-path
```
This replaces manually running the installation scripts for package installation
and setup of supported packages and system configurations.

### `please` install
For installing specific packages that may require more setup than a single
pacman command

```bash
# So you can run:
please install rust

# Instead of:
#
# sudo pacman -Sy rustup
# rustup default stable
#
```
You can list available packages with:
```bash
please install --list
```
But the best feature of `please` in my opinion, is the ability to cleanly remove
these packages from your system:
```bash
please uninstall rust
```

### `please` setup
For setting up complex system configurations

For example, setting up your system for gaming takes quite a lot of 
configuration, but `please` makes it as easy as
```bash
please setup gaming
```
And to cleanly undo everything that sets up, just run:
```
please remove-setup gaming
```

### Replaces the Arch-Configurations repo
The Arch-Configurations installation script and directories have been moved
into and updated to work with Arch-Setup.

The installation is now ran after nearly every `please <command>` call, but it
can also be manually called:
```bash
please add-configs
```
The script that `add-configs` calls is much smarter than what Arch-Configurations
had. It now only runs steps that haven't already been ran. So most of the time it
will have no output.

## Errors
* All error logs will be written to `/tmp/archsetuperrors.log` (which will be 
  deleted at reboot)
