class_name Config
extends Node

const configFile = "config.ocl"

# Called when the node enters the scene tree for the first time.
func _ready():
	# OS.set_window_position((OS.get_screen_size(screen) * 0.5) - (defaultWindowSize * 0.5))
	print(OS.get_user_data_dir())
	pass # Replace with function body.

func loadConfig(path, target):
	print("TODO")
	print("Load config: ", OS.get_user_data_dir(), "/", path[0])

func moveWindowToScreen(screen, target):
	OS.set_current_screen(screen[0])
	# OS.set_window_position(OS.get_window_position())

func setWindowPosition(pos, target):
	print("window position: ", pos)
	OS.set_window_position(Vector2(pos[0], pos[1]))

func centerWindow(args, sender):
	OS.set_window_position((OS.get_screen_size(OS.get_current_screen()) * 0.5) - (OS.get_window_size() * 0.5))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
