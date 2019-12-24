# Home Duplicating

## Overview

This is a mod for the game of Don't Starve Together which is available in the Steam Workshop. 

The mod allows you to duplicate your home from one server to another server. And it can duplicate your home in the same server, too.

And of couse, you should be a game admin to use it.

**Usage**

Press `Y` or `U` and type the following commands to excute it in the chatting window:

- `+record`

    You should add a number as the a side length of a square. For example, `+record5` mean that you will set a square area whose center is your character's location and whose side length is 5 turf length. System will record every structure and plant inside the square area and will record the tile, too.

- `+deploy`

    Just type `+deploy` in the chatting window, system will automatically copy your home into the square area as you previously recorded. The square area center is also the location of your character.

- `+wipe`

    You should add a number as the a side length of a square. `+wipe` mean that you will set a square area whose center is your character's location and whose side length is 5 turf length. System will remove every structure and plant inside the square area. **Use it with caution.**

BTW, the center of the square area is not exactly the character's location. It is the cross point of tile (when holding a pitchfork, your will see the lines and it's the intersection of the crosslines) which is the closest to the location of your character.

The Data of your base will be saved in the Mod folder `mods\workshop-1942653373`. The files name `homedata` and `tiledata`. If you are holding a dedicated server, the files are in the mod folder of the dedicated server because it's a server-only mod. You can send these two files to your friends to duplicate a base immediately.

## Changelog

**List of tweaks I made for version 1.4.0**

- Now we can record things in the chest and deploy them.
- Change the save location.

## License

Released under the [GNU GENERAL PUBLIC LICENSE](https://www.gnu.org/licenses/gpl-3.0.en.html)