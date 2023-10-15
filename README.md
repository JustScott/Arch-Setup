# configs
All of my scripts for installing certain sets of software in arch linux.


### Base Scripts
* Run `host.sh` to install the basic host system packages
* Run `user.sh` to configure user specific settings ( without sudo )

### Extended Scripts
* Run `qemu.sh` to install and configure the necessary tools to run virtual machines
* Run `secure.sh` to extend the system security

### Environment Scripts
* Run `dwm.sh` to configure the system for dwm
* Run `gnome.sh` to configure the system for gnome

### Virtual Machines
If creating a virtual machine, don't run any scripts but the virtual machine
script as it already calls the needed scripts. `flutter_development.sh` is an
exception to that rule, you must run `dwm.sh` before running the flutter script.
