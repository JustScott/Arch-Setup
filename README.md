# configs
All of my scripts for installing certain sets of software in arch linux.


### Base installation
* Run `host.sh` to install the basic host system packages
* Run `user.sh` to configure user specific settings ( without sudo )

### Extended installation
* Run `qemu.sh` to install and configure the necessary tools to run virtual machines
* Run `secure.sh` to extend the system security

### Environment setup
* Run `dwm.sh` to configure and install the dwm Window Manager
* Run `gnome.sh` to configure and install the Gnome Desktop Environment

### Install scripts to `/usr/local/bin` (will overwrite existing files) 
* Run `dwm-scripts.sh` to install dwm specific scripts
* Run `general-scripts.sh` to install general scripts

### Virtual Machines
If creating a virtual machine, don't run any scripts but the virtual machine
script as it already calls the needed scripts. `flutter_development.sh` is an
exception to that rule, you must run `dwm.sh` before running the flutter script.

### Errors
* All error logs will be written to `/tmp/archsetuperrors.log` (which will be 
  deleted at reboot)
