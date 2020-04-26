name = "Home Duplicating"
description = [[
The mod allows you to duplicate your home from one server to another server.
And it can duplicate your home in the same server, too.
]]
author = "辣椒小皇纸"
version = "1.6.0"

forumthread = ""

dont_starve_compatible = false
reign_of_giants_compatible = false
dst_compatible = true

api_version =  10

all_clients_require_mod = false
client_only_mod = false

icon_atlas = "modicon.xml"
icon = "modicon.tex"

configuration_options =
{
    {
        name = "reeds_copy",
        label = "Reeds Duplicating",
        hover = "",
        options =
    {
        {description = "Yes", data = true, hover = ""},
        {description = "No", data = false, hover = ""},
    },
        default = false,
    },
    {
        name = "shell_copy",
        label = "Singing Shell Duplicating",
        hover = "",
        options =
    {
        {description = "Yes", data = true, hover = ""},
        {description = "No", data = false, hover = ""},
    },
        default = false,
    }
}