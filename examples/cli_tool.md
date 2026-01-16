```bash
#!/bin/bash
#
# tool - part of the My-Project project
# Copyright (C) 2026, JustScott, development@justscott.me
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
# Explain your tool
#


display_help() {
    echo -e "\nUsage: tool [COMMAND]"
    echo -e "\nDoes something\n"

    echo "Commands:"
    printf "\t%-15s %-1s\n" "command" "This command does something"
    printf "\t%-15s %-1s\n" "version" "Returns version information"

    echo -e "\nCommand Flags:\n"
    echo -e "\tcommand:"
    printf "\t    %-20s\t %-1s\n" "-l | --list" "List command stuff"
    
    echo -e "\nExamples:"
    echo -e "\t\`command --list\`"

    echo -e "\nError Codes:"
    printf "\t%-3s %-1s\n" "1" "Invalid command"
}

command() {
    local \
        commands_to_run \
        FLAG_list_commands

    for arg in $@
    do
        case $arg in
            "-l" | "--list")
                [[ -n "$FLAG_list_commands" ]] && {
                    echo -e "\n - [ERROR] duplicated the list commands flag - \n"
                    exit 1
                }
                FLAG_list_commands=1
            ;;
            *)
                # Support flags starting with '-' or "--" shouldn't reach
                # the catchall case
                if [[ $arg =~ ^-{1,2} ]]
                then
                    echo "The '$arg' flag isn't supported"
                    exit 1
                fi
                commands_to_run+=($arg)
            ;;
        esac
    done

    if ((FLAG_list_commands))
    then
        echo "List flag on"
    else
        echo "List flag off"
    fi

    echo "PACKAGES: ${commands_to_run[@]}"
}

place_holder() {
    echo $@
}

case $1 in
    "command")              command ${@:2};;
    "future_command")       place_holder ${@:2};;
    "version"|"--version")  echo "0.1.0";;
    "--help"|"-h")          display_help;;
    *) 
        printf "\n\n - [ERROR] Invalid use of the \`command\` command -";
        display_help
        exit 1
        ;;
esac
```
