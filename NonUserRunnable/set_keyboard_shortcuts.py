#
# set_keyboard_shortcuts.py - part of the Arch-Setup project
# Copyright (C) 2023, Scott Wyman, development@scottwyman.me
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


import os

__author__ = "Scott Wyman (development@scottwyman.me)"

__license__ = "GPLv3"

__date__ = "September 6, 2023"

__all__ = []

__doc__ = (
'''
Sets the keyboard shortcuts for the gnome desktop environment in Arch Linux
'''
)


shortcuts = {
    'Terminal': {
        'key_binding':'<Ctrl><Alt>t',
        'command':'gnome-terminal'
    },
    'Browser': {
        'key_binding':'<Ctrl><Shift>b',
        'command':'xdg-open https://'
    },
    'AUR': {
        'key_binding':'<Ctrl><Alt>a',
        'command':'xdg-open https://wiki.archlinux.org'
    },
}

def set_bindings_template():
    binding_settings = []
    setting_arguments = 'gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings'

    for count in range(len(shortcuts)):
        setting = f'/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom{count}/'
        binding_settings.append(setting)

    os.system(f'{setting_arguments} "{str(binding_settings)}"')

def set_keybindings():
    for name,count in zip(shortcuts,range(len(shortcuts))):
        binding = shortcuts[name]['key_binding']
        command = shortcuts[name]['command']
        
        os.system(f'''gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom{count}/ binding "{binding}"''')
        os.system(f'''gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom{count}/ command "{command}"''')
        os.system(f'''gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom{count}/ name "{name}"''')


if __name__=='__main__':
    set_bindings_template()
    set_keybindings()

