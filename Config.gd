class_name Config
extends Node

onready var cmds = get_parent().find_node("CustomCommands")
onready var osc = get_parent().find_node("OscInterface")
const configFile = "config.osc"

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Data dir: ", OS.get_user_data_dir())
	pass # Replace with function body.

func loadConfig(args, sender):
	print("TODO")
	print("Load config: ", OS.get_user_data_dir(), "/", args[0])

	print(cmds)
	if args.size() != 1:
		osc.reportError("loadConfig expects one argument", sender)
		return

	var configFile = "res://config/" + args[0]
	if not cmds.loadCommandFile(configFile):
		osc.reportError("Couldn't open config file: '%s'" % [configFile], sender)

func moveWindowToScreen(screen, sender):
	OS.set_current_screen(screen[0])

func setWindowPosition(pos, sender):
	print("window position: ", pos)
	OS.set_window_position(Vector2(pos[0], pos[1]))

func centerWindow(args, sender):
	OS.set_window_position((OS.get_screen_size(OS.get_current_screen()) * 0.5) - (OS.get_window_size() * 0.5))

