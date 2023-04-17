extends Node
class_name Config

onready var cmds : CustomCommands = get_parent().find_node("CustomCommands")
onready var osc = get_parent().find_node("OscInterface")
const defaultConfigDir := "config/"
var defaultMidiFile := "commands/midi.osc"
var animationAssetPath := Helper.getGlobalPath("animations/") setget animPathSet
var allowRemoteClients := true

# Called when the node enters the scene tree for the first time.
func _ready():
	Logger.info("User data dir: %s" % [OS.get_user_data_dir()])


############################################################
# Helpers
############################################################
func animPathSet(path):
	animationAssetPath = Helper.getGlobalPath(path)


############################################################
# OSC config commands
############################################################
func loadConfig(args, sender):
#	print(cmds)
	if args.size() != 1:
		osc.reportError("loadConfig expects one argument", sender)
		return
	var configFile = Helper.getPathWithDefaultDir(args[0], defaultConfigDir)
	if cmds.loadCommandFile(configFile):
		osc.reportStatus("Loaded config from '%s'" % configFile, sender)
	else:
		osc.reportError("Couldn't open config file: '%s'" % [configFile], sender)


func moveWindowToScreen(screen, sender):
	OS.set_current_screen(int(screen[0]))


func setWindowPosition(pos, sender):
	Logger.debug("window position: %s" % [pos])
	OS.set_window_position(Vector2(pos[0], pos[1]))


func setWindowSize(args, sender):
	Logger.debug("window size: %s" % [args])
	var size = Vector2(args[0], args[1])
	var vp = get_viewport()
	var aspect = vp.size.x / vp.size.y
	if size.y < 0:
		size.y = size.x / aspect
	elif size.x < 0:
		size.x = size.y * aspect
	OS.set_window_size(size)


func centerWindow(args, sender):
	if not args.empty():
		osc.reportError("centerWindow expects no arguments", sender)
		return
	OS.set_window_position((OS.get_screen_size(OS.get_current_screen()) * 0.5) - (OS.get_window_size() * 0.5))


func fullscreen(args, sender):
	var fs = true if args.empty() else Helper.getBool(args[0])
	OS.set_window_fullscreen(fs)


func windowAlwaysOnTop(args, sender):
	var ot = true if args.empty() else Helper.getBool(args[0])
	OS.set_window_always_on_top(ot)


# This method sets the path, but also reports it back if run without args
func setAnimationAssetPath(args, sender):
	var msg = "Asset path: "
	if args.size() == 1:
		msg = "Set " + msg
		self.animationAssetPath = args[0]
	if Directory.new().dir_exists(animationAssetPath):
		osc.reportStatus(msg + animationAssetPath, sender)
	else:
		osc.reportError("Invalid animation path: '%s'" % animationAssetPath, sender)


func setAppRemote(args, sender):
	allowRemoteClients = true if args.empty() else Helper.getBool(args[0])

