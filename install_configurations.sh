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

{
    extension_path="$CONFIGS_DIRECTORY/bashrc_extension"
    if ! grep "source $extension_path" $HOME/.bashrc &>/dev/null
    then
        echo -e "\nsource $extension_path" \
            >> $HOME/.bashrc 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" \
            "Source bashrc_extension in $HOME/.bashrc"
    fi
} 

if { which nvim || type nvim; } &>/dev/null
then
    if ! [[ -L "$HOME/.vimrc" ]]
    then
        ln -sf $CONFIGS_DIRECTORY/init.vim $HOME/.vimrc \
            >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" \
            "Create soft link for '\$HOME/.vimrc'"
    fi

    if ! [[ -d "$HOME/.config/nvim" && -L "$HOME/.config/nvim/init.vim" ]]
    then
        {
            mkdir -p $HOME/.config/nvim
            ln -sf $CONFIGS_DIRECTORY/init.vim $HOME/.config/nvim
        } >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" \
            "Create soft link for '\$HOME/.config/nvim'"
    fi

    # Install Vim-Plug for adding pluggins to vim and neovim
    if ! [ -f "$HOME/.local/share/nvim/site/autoload/plug.vim" ]
    then
        mkdir -p $HOME/.local/share/nvim/site/autoload &>/dev/null
        {
            curl -Lo $HOME/.local/share/nvim/site/autoload/plug.vim \
                https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
            nvim -c "PlugInstall | qall" --headless
        } >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" "Download & Install vim-plug"
    fi
fi

if { which git || type git; } &>/dev/null
then
    git_config="$(git config --list)"
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

    if { which bat || type bat; } &>/dev/null
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

if { which lf || type lf; } &>/dev/null
then
    if ! [[ \
        -d "$HOME/.config/lf" \
        && -L "$HOME/.config/lf/lfrc" \
        && -L "$HOME/.config/lf/previewer.sh" \
    ]]
    then
        {
            mkdir -p $HOME/.config/lf
            ln -sf $CONFIGS_DIRECTORY/lf/{lfrc,previewer.sh} $HOME/.config/lf/
        } >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" \
            "Create soft link to '\$HOME/.config/lf/{lfrc,previewer.sh}'"
    fi
fi

if { which calcurse || type calcurse; } &>/dev/null
then
    if ! [[ -d "$HOME/.config/calcurse" && -L "$HOME/.config/calcurse/conf" ]]
    then
        {
            mkdir -p $HOME/.config/calcurse
            ln -sf $CONFIGS_DIRECTORY/calcurse/conf $HOME/.config/calcurse/
        } >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" \
            "Create soft link to '\$HOME/.config/calcurse/conf'"
    fi
fi

if { which bat || type bat; } &>/dev/null
then
    if ! [[ -d "$HOME/.config/bat" && -L "$HOME/.config/bat/config" ]]
    then
        {
            mkdir -p $HOME/.config/bat
            ln -sf $CONFIGS_DIRECTORY/bat/config $HOME/.config/bat/config
        } >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
        task_output $! "$STDERR_LOG_PATH" \
            "Create soft link to '\$HOME/.config/bat/config'"
    fi
fi

if { which newsboat || type newsboat; } &>/dev/null
then
    if ! [[ \
        -d "$HOME/.config/newsboat" \
        && -L "$HOME/.config/newsboat/config" \
        && -L "$HOME/.config/newsboat/urls" \
    ]]
    then
        {
            mkdir -p $HOME/.config/newsboat
            ln -sf $CONFIGS_DIRECTORY/newsboat/{config,urls} \
                $HOME/.config/newsboat/
        } >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
            task_output $! "$STDERR_LOG_PATH" \
                "Create soft link to '\$HOME/.config/newsboat/{config,urls}'"
    fi
fi

if { which mpv || type mpv; } &>/dev/null
then
    if ! [[ -d "$HOME/.config/mpv" && -L "$HOME/.config/mpv/mpv.conf" ]]
    then
        {
            mkdir -p $HOME/.config/mpv
            ln -sf $CONFIGS_DIRECTORY/mpv/mpv.conf $HOME/.config/mpv/
        } >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
            task_output $! "$STDERR_LOG_PATH" \
                "Create soft link to '\$HOME/.config/mpv/mpv.conf'"
    fi
fi

if { which ytfzf || type ytfzf; } &>/dev/null
then
    if ! [[ -d "$HOME/.config/ytfzf" && -L "$HOME/.config/ytfzf/conf.sh" ]]
    then
        {
            mkdir -p $HOME/.config/ytfzf
            ln -sf $CONFIGS_DIRECTORY/ytfzf/conf.sh $HOME/.config/ytfzf/
        } >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
            task_output $! "$STDERR_LOG_PATH" \
                "Create soft link to '\$HOME/.config/ytfzf/conf.sh'"
    fi
fi

if { which qutebrowser || type qutebrowser; } &>/dev/null
then
    if ! [[ \
        -d "$HOME/.config/qutebrowser" \
        && -L "$HOME/.config/qutebrowser/blocked-hosts" \
        && -L "$HOME/.config/qutebrowser/quickmarks" \
    ]]
    then
        {
            mkdir -p $HOME/.config/qutebrowser
            ln -sf $CONFIGS_DIRECTORY/qutebrowser/{blocked-hosts,quickmarks} \
                $HOME/.config/qutebrowser/
        } >>"$STDOUT_LOG_PATH" 2>>"$STDERR_LOG_PATH" &
            task_output $! "$STDERR_LOG_PATH" \
                "Create soft link to '\$HOME/.config/qutebrowser/{blocked-hosts,quickmarks}'"
    fi
fi
