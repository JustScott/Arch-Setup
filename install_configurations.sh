#!/bin/bash
#
# install.sh - part of the Arch-Setup project
# Copyright (C) 2023-2026, JustScott, development@justscott.me
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
# Creates soft links to all of the configuration files in this repository
#  throughout the system.
#

PRETTY_OUTPUT_LIBRARY="./GeneralLibraries/pretty_output_library.sh"

if ! source "$PRETTY_OUTPUT_LIBRARY" &>/dev/null
then
    printf "\n\e[31m%s\e[0m %s\n" "[Error]" \
        "Could'nt source '$PRETTY_OUTPUT_LIBRARY', this shouldn't happen. Stopping."
    exit 1
fi

CONFIGS_DIRECTORY="$(pwd)/Configurations"

REQUIRED_COMMANDS=(mkdir grep printf curl)

ensure_commands_installed()
{
    for cmd in ${REQUIRED_COMMANDS[@]}
    do
        if ! command -v $cmd &>/dev/null
        then
            printf "\n\n\e[31m%s %s\e[0m\n\n" \
                "[!] Missing required command: '$cmd'."
            return 1
        fi
    done

    return 0
}

ensure_commands_installed || exit $?

configure_bashrc_extension()
{
    local extension_path="${CONFIGS_DIRECTORY}/bashrc_extension"
    if ! grep "^source $extension_path$" "${HOME}/.bashrc" &>/dev/null
    then
        echo "source $extension_path" >> "${HOME}/.bashrc" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" \
            "Source bashrc_extension in ${HOME}/.bashrc"
    fi
} 

configure_bashrc_secrets()
{
    local secrets_path="\$HOME/.bashrc_secrets"
    if ! grep "^source $secrets_path$" "${HOME}/.bashrc" &>/dev/null
    then
        echo "source $secrets_path" >> "${HOME}/.bashrc" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" \
            "Source bashrc_extension in ${HOME}/.bashrc"
    fi
}

configure_vim()
{
    if command -v vim &>/dev/null
    then
        if ! cat "${HOME}/.vimrc" &>/dev/null
        then
            ln -sf "${CONFIGS_DIRECTORY}/nvim/init.vim" \
                 "${HOME}/.vimrc" \
                 >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
            task_output $! "$STDERR_LOG_PATH" \
                "Create soft link to '\$HOME/.vimrc'"
        fi
    fi
}

configure_vim_plug()
{
    if command -v nvim &>/dev/null
    then
        # Install Vim-Plug for adding pluggins to vim and neovim
        if ! [[ -f "${HOME}/.local/share/nvim/site/autoload/plug.vim" ]]
        then
            mkdir -p "${HOME}/.local/share/nvim/site/autoload" &>/dev/null

            curl -Lo "${HOME}/.local/share/nvim/site/autoload/plug.vim" \
                https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
                >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
            task_output $! "$STDERR_LOG_PATH" "Download & Install vim-plug"

            nvim -c "PlugInstall | qall" --headless \
                >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
            task_output $! "$STDERR_LOG_PATH" "Install plugins with vim-plug"
        fi
    fi
}

configure_git()
{
    if command -v git &>/dev/null
    then
        local git_config="$(git config --list)"

        if ! echo "$git_config" | grep "user.email=development@justscott.me" \
            &>/dev/null
        then
            git config --global user.email development@justscott.me \
                >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
            task_output $! "$STDERR_LOG_PATH" \
                "Configure global git user.email as development@justscott.me"
        fi
        if ! echo "$git_config" | grep "user.name=JustScott" \
            &>/dev/null
        then
            git config --global user.name JustScott \
                >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
            task_output $! "$STDERR_LOG_PATH" \
                "Configure global git user.name as JustScott"
        fi

        if command -v bat &>/dev/null
        then
            if ! echo "$git_config" | grep \
                "core.pager=bat --paging=always --style=changes" \
                &>/dev/null
            then
                git config --global core.pager \
                    "bat --paging=always --style=changes" \
                    >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
                task_output $! "$STDERR_LOG_PATH" \
                    "Configure global git core.pager as bat"
            fi
        fi
    fi
}

configure_tool()
{
    local tool="$1"
    shift
    local file_names=("$@")

    if command -v $tool &>/dev/null
    then
        if ! [[  -d "${HOME}/.config/${tool}" ]]
        then
            mkdir -p "${HOME}/.config/${tool}" \
                >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
            task_output $! "$STDERR_LOG_PATH" \
                "Create the '\$HOME/.config/${tool}' directory"
        fi

        for file_name in ${file_names[@]}
        do
            if ! cat "${HOME}/.config/${tool}/${file_name}" &>/dev/null
            then
                ln -sf "${CONFIGS_DIRECTORY}/${tool}/${file_name}" \
                     "${HOME}/.config/${tool}/" \
                     >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
                task_output $! "$STDERR_LOG_PATH" \
                    "Create soft link to '\$HOME/.config/${tool}/${file_name}'"
            fi
        done
    fi 
}

configure_tool nvim init.vim
configure_tool bat config
configure_tool mpv mpv.conf
configure_tool ytfzf conf.sh
configure_tool calcurse conf
configure_tool lf lfrc previewer.sh
configure_tool newsboat config urls
configure_tool qutebrowser blocked-hosts quickmarks

configure_bashrc_extension
configure_bashrc_secrets
configure_vim
configure_vim_plug
configure_git
