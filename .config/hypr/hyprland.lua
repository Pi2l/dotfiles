---@diagnostic disable: lowercase-global
local configs = "configs"

-- ###################
-- ### MY PROGRAMS ###
-- ###################
-- See https://wiki.hyprland.org/Configuring/Keywords/

-- Set programs that you use
terminal = "kitty"
fileManager = "nautilus"
menu = "wofi --show drun"

require(configs .. "/monitors")
require(configs .. "/autostarts")
require(configs .. "/envs")
require(configs .. "/appearences")
require(configs .. "/inputs") -- also gestures
require(configs .. "/keybindings")

-- ##############################
-- ### WINDOWS AND WORKSPACES ###
-- ##############################

-- # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
-- # See https://wiki.hyprland.org/Configuring/Workspace-Rules/ for workspace rules
require(configs .. "/windowrules")
