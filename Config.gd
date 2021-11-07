class_name Config
extends Node

onready var cmds = get_parent().find_node("CustomCommands")
onready var osc = get_parent().find_node("OscInterface")
var defaultConfigDir = "res://config/"
var defaultConfigFile = defaultConfigDir + "config.osc"
var animationAssetPath = "res://animations/"

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Data dir: ", OS.get_user_data_dir())
	# loadConfig([defaultConfigFile], null)
	# get_parent().evalOscCommand("/config", [], null)
	# osc.sendMessage(oscServer, "/load/config", ["config.osc"])
	# osc.sendMessage(oscServer, "/config", [])
	pass # Replace with function body.

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
	OS.set_window_fullscreen(bool(args[0]))

func setAnimationAssetPath(args, sender):
	animationAssetPath = args[0]
	osc.reportStatus("Asset path: " + animationAssetPath, sender)

func getAnimationAssetPath(sender):
	osc.reportStatus(animationAssetPath, sender)
	return animationAssetPath
