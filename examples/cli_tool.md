```bash
#!/bin/bash
#
# arch - part of the Arch-Setup project
# Copyright (C) 2025, JustScott, development@justscott.me
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.


#
# CLI tool to replace Arch-Setup and Arch-Configurations. It will
#  make the process of installing software and having them automatically
#  configured to my setup much easier.
#


display_help() {
    echo -e "\nUsage: arch [COMMAND]"
    echo -e "\nSimplifies Arch-Setup and Arch-Configurations into a single"
    echo -e " CLI tool with many more automated features.\n"

    echo "Commands:"
    printf "\t%-15s %-1s\n" "install" "Install supported software"
    printf "\t%-15s %-1s\n" "uninstall" "Cleanly uninstall supported software"
    printf "\t%-15s %-1s\n" "setup" "Setup groups of software packages"
    printf "\t%-15s %-1s\n" "preset" "Pre-setup the system in a specifc way"
    printf "\t%-15s %-1s\n" "version" "Returns version information"

    echo -e "\nCommand Flags:\n"
    echo -e "\tinstall:"
    printf "\t    %-20s\t %-1s\n" "-l | --list" "List installable software"
    echo -e "\tuninstall:"
    printf "\t    %-20s\t %-1s\n" "-l | --list" "List installed software"
    echo -e "\tsetup:"
    printf "\t    %-20s\t %-1s\n" "-u | --undo" "Cleanly remove the setup"
    echo -e "\tpreset:"
    printf "\t    %-20s\t %-1s\n" "-u | --undo" "Cleanly remove the preset"
    
    echo -e "\nExamples:"
    echo -e "\t\`arch install --list\`"
    echo -e "\t\`arch uninstall --list\`"
    echo -e "\t\`arch install qutebrowser\`"
    echo -e "\t\`arch install user-scripts\`"
    echo -e "\t\`arch uninstall qutebrowser\`"
    echo -e "\t\`arch setup river rust bluetooth\`"
    echo -e "\t\`arch setup security\`"
    echo -e "\t\`arch setup --undo rust\`"
    echo -e "\t\`arch preset base host base_vm\`"
    echo -e "\t\`arch preset --undo base_vm\`"

    echo -e "\nError Codes:"
    printf "\t%-3s %-1s\n" "1" "Invalid command"
    printf "\t%-3s %-1s\n" "2" "Can't be uninstalled or removed as it doesn't exist"
}

install() {
    local \
        packages_to_install \
        FLAG_list_packages

    for arg in $@
    do
        case $arg in
            "-l" | "--list")
                [[ -n "$FLAG_list_packages" ]] && {
                    echo -e "\n - [ERROR] duplicated the list packages flag - \n"
                    exit 1
                }
                FLAG_list_packages=1
            ;;
            *)
                # Support flags starting with '-' or "--" shouldn't reach
                # the catchall case
                if [[ $arg =~ ^-{1,2} ]]
                then
                    echo "The '$arg' flag isn't supported"
                    exit 1
                fi
                packages_to_install+=($arg)
            ;;
        esac
    done

    if ((FLAG_list_packages))
    then
        echo "List flag on"
    else
        echo "List flag off"
    fi

    echo "PACKAGES: ${packages_to_install[@]}"
}

place_holder() {
    echo $@
}

case $1 in
    "install")      install ${@:2};;
    "setup")        place_holder ${@:2};;
    "preset")       place_holder ${@:2};;
    "version"|"--version") echo "0.1.0";;
    "--help"|"-h") display_help;;
    *) 
        echo -e "\n - [ERROR] Invalid use of the \`arch\` command -";
        display_help
        exit 1
        ;;
esac
```
