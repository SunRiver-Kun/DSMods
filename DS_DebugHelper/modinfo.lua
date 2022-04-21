-- This information tells other players more about the mod
name = "DS_DebugHelper"
description = ""
author = "SunRiver"
version = "1.0"

forumthread = ""

-- This lets other players know if your mod is out of date, update it to match the current version in the game
api_version = 6

dont_starve_compatible = true
reign_of_giants_compatible = true
shipwrecked_compatible = true

-- Can specify a custom icon for this mod!
icon_atlas = "modicon.xml"
icon = "modicon.tex"

-- Specify the priority
priority = 9
	
configuration_options =
{
	
	{
		name = "AutoGodMode",
		label = "自动启用上帝模式",
		options =	{
						{description = "是", data = true},
						{description = "否", data = false},
					},

		default = true,
	},
}