class_name Config
extends Node

onready var cmds : CustomCommands = get_parent().find_node("CustomCommands")
onready var osc = get_parent().find_node("OscInterface")
var defaultConfigDir = "res://config/"
var defaultConfigFile = defaultConfigDir + "config.osc"
var animationAssetPath = "res://animations/" setget animPathSet


# Called when the node enters the scene tree for the first time.
func _ready():
	print("Data dir: ", OS.get_user_data_dir())


func loadConfig(args, sender):
	print(cmds)
	if args.size() != 1:
		osc.reportError("loadConfig expects one argument", sender)
		return
	var configFile = args[0]
	if not cmds.loadCommandFile(configFile):
		osc.reportError("Couldn't open config file: '%s'" % [configFile], sender)


func moveWindowToScreen(screen, sender):
	OS.set_current_screen(int(screen[0]))


func setWindowPosition(pos, sender):
	print("window position: ", pos)
	OS.set_window_position(Vector2(pos[0], pos[1]))


func centerWindow(args, sender):
	OS.set_window_position((OS.get_screen_size(OS.get_current_screen()) * 0.5) - (OS.get_window_size() * 0.5))


func fullscreen(args, sender):
	var fs = true if args.empty() else bool(args[0])
	OS.set_window_fullscreen(fs)


# This method sets the path, but also reports it back if run without args
func setAnimationAssetPath(args, sender):
	var msg = "Asset path: "
	if args.size() == 1:
		msg = "Set " + msg
		self.animationAssetPath = args[0]
	osc.reportStatus(msg + animationAssetPath, sender)


func animPathSet(path):
	if path.begins_with("/") or path.begins_with("res://"):
		animationAssetPath = path
	else:
		animationAssetPath = "res://" + path

