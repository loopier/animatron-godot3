extends Node2D

var oscrcv
# Actor commands:
#   The first argument for all these commands is the target actor(s).
#   It may be "!" (selection), an actor instance name or a wildcard string.
onready var actorCmds = {
	"/free": funcref($OscInterface, "freeActor"),
	"/anim": funcref($OscInterface, "setActorAnim"),
	"/play": funcref($OscInterface, "playActor"),
	"/play/rand": funcref($OscInterface, "playActorRandom"),
	"/play/reverse": funcref($OscInterface, "playActorReverse"),
	"/stop": funcref($OscInterface, "stopActor"),
	"/frame": funcref($OscInterface, "setActorFrame"),
	"/position": funcref($OscInterface, "setActorPosition"),
	"/position/x": funcref($OscInterface, "setActorPositionX"),
	"/position/y": funcref($OscInterface, "setActorPositionY"),
	"/rotate": funcref($OscInterface, "setActorRotation"),
	"/scale": funcref($OscInterface, "setActorScale"),
	"/scale/xy": funcref($OscInterface, "setActorScaleXY"),
	"/scale/x": funcref($OscInterface, "setActorScaleX"),
	"/scale/y": funcref($OscInterface, "setActorScaleY"),
	"/pivot": funcref($OscInterface, "setActorPivot"),
	"/fade": funcref($OscInterface, "setActorFade"),
	"/speed": funcref($OscInterface, "setActorSpeed"),
	"/fliph": funcref($OscInterface, "flipActorH"),
	"/flipv": funcref($OscInterface, "flipActorV"),
	"/color": funcref($OscInterface, "colorActor"),
	"/color/r": funcref($OscInterface, "colorRedActor"),
	"/color/g": funcref($OscInterface, "colorGreenActor"),
	"/color/b": funcref($OscInterface, "colorBlueActor"),
	"/say": funcref($OscInterface, "sayActor"),
	"/action": funcref($OscInterface, "actionActor"),
	"/behind": funcref($OscInterface, "behindActor"),
	"/front": funcref($OscInterface, "frontActor"),
	"/sound": funcref($OscInterface, "soundActor"),
	"/sound/free": funcref($OscInterface, "soundFreeActor"),
	"/midi": funcref($OscInterface, "midiActor"),
	"/midi/free": funcref($OscInterface, "midiFreeActor"),
	"/onframe": funcref($OscInterface, "onFrameActor"),
	"/onfinish": funcref($OscInterface, "onFinishActor"),
	"/onframe/free": funcref($OscInterface, "onFrameFreeActor"),
	"/onfinish/free": funcref($OscInterface, "onFinishFreeActor"),
	"/list/sequence": funcref($OscInterface, "getSequenceActor"),
}

onready var otherCmds = {
	"/load": funcref($OscInterface, "loadAsset"),
	"/create": funcref($OscInterface, "createActor"),
	"/create/group": funcref($OscInterface, "createActorGroup"),
	"/createordestroy": funcref($OscInterface, "createOrDestroyActor"),
	"/ysort": funcref($OscInterface, "ySortActors"),
	"/list": funcref($OscInterface, "listActors"), # shortcut for /list/actors
	"/list/actors": funcref($OscInterface, "listActors"),
	"/list/anims": funcref($OscInterface, "listAnims"),
	"/list/assets": funcref($OscInterface, "listAssets"),
	"/group": funcref($OscInterface, "groupActor"),
	"/ungroup": funcref($OscInterface, "ungroupActor"),
	"/select": funcref($OscInterface, "selectActor"),
	"/deselect": funcref($OscInterface, "deselectActor"),
	"/selected": funcref($OscInterface, "listSelectedActors"),
	"/def": funcref($OscInterface, "defCommand"),
	"/load/defs": funcref($OscInterface, "loadDefsFile"),
	"/debug": funcref($OscInterface, "enableStatusMessages"),
	"/midi/debug": funcref($OscInterface, "midiEnableStatusMessages"),
	"/list/midi": funcref($OscInterface, "listMidiCmds"),
	
	#rand	
	"/rand": funcref($OscInterface, "randCmdArg"),
	"/choose": funcref($OscInterface, "chooseCmd"),
	
	# time
	# "/wait" command is handled specially 	
	"/routine": funcref($OscInterface, "newRoutine"),
	"/routine/start": funcref($OscInterface, "startRoutine"),
	"/routine/stop": funcref($OscInterface, "stopRoutine"),
	"/routine/free": funcref($OscInterface, "freeRoutine"),
	"/list/routines": funcref($OscInterface, "listRoutines"),
	
	# write
	"/load/alphabet": funcref($Letters, "loadAlphabet"),
	"/write": funcref($Letters, "write"),
	"/letter": funcref($Letters, "setLetter"),
	"/letters/spacing": funcref($Letters, "setSpacing"),
	"/letters/scale": funcref($Letters, "setScale"),

	# app
	"/bg": funcref($OscInterface, "setBackgroundColor"),
	"/list/commands": funcref($OscInterface, "listCommands"),
	"/help": funcref($OscInterface, "openHelp"),
	"/user/datapath": funcref($OscInterface, "postUserDataPath"),
	
	# editor
	"/tutorial": funcref($OscInterface, "loadTutorial"),
	"/editor/open": funcref($OscInterface, "openFile"),
	"/editor/save": funcref($OscInterface, "saveFile"),
	"/editor/append": funcref($OscInterface, "editorAppend"),
	"/editor/font/size": funcref($OscInterface, "editorFontSize"),
	"/editor/font/increase": funcref($OscInterface, "editorIncreaseFont"),
	"/editor/font/decrease": funcref($OscInterface, "editorDecreaseFont"),
	"/post": funcref($OscInterface, "postMsg"),
	"/post/font/size": funcref($OscInterface, "postFontSize"),
	"/post/font/increase": funcref($OscInterface, "postIncreaseFont"),
	"/post/font/decrease": funcref($OscInterface, "postDecreaseFont"),
	
	# logger
	"/log": funcref($OscInterface, "logMsg"),
	"/log/level": funcref($OscInterface, "setLogLevel"),
	
	# osc
	"/osc/remote": funcref($OscInterface, "connectOscRemote"),
	"/osc/send": funcref($OscInterface, "sendOsc"),

	# config commands
	"/load/config": funcref($Config, "loadConfig"),
	"/assets/path": funcref($Config, "setAnimationAssetPath"),
	"/app/remote": funcref($Config, "setAppRemote"),

	# app window
	"/window/screen": funcref($Config, "moveWindowToScreen"),
	"/window/position": funcref($Config, "setWindowPosition"),
	"/window/size": funcref($Config, "setWindowSize"),
	"/window/center": funcref($Config, "centerWindow"),
	"/window/fullscreen": funcref($Config, "fullscreen"),
	"/window/top": funcref($Config, "windowAlwaysOnTop"),
}


func getActorCommandSummary() -> String:
	return (actorCmds.keys() as PoolStringArray).join('\n')


func getOtherCommandSummary() -> String:
	return (otherCmds.keys() as PoolStringArray).join('\n')
	

func _ready():	
	Logger.setLevel(Logger.LOG_LEVEL_INFO)
	Logger.setTarget(get_node("PostTextEdit"))
	randomize()
		
	# See: https://gitlab.com/frankiezafe/gdosc
	oscrcv = load("res://addons/gdosc/gdoscreceiver.gdns").new()
	# [optional] maximum number of messages in the buffer, default is 100
	oscrcv.max_queue( 256 )
	# [optional]  receiver will only keeps the "latest" message for each address
	oscrcv.avoid_duplicate( false )
	# [mandatory] listening to port 14000
	oscrcv.setup( 56101 )
	# [mandatory] starting the reception of messages
	oscrcv.start()
	
	# Load initial set of custom command definitions (if it exists)
	$OscInterface.loadDefsFile(["init.osc"], null)
	
	# Load default config file (if it exists) and call config command
	$Config.loadConfig(["config.osc"], null)
	evalCommandList([["/config"]], null)
	
	var w = OS.get_window_size().x
	var h = OS.get_window_size().y
	var gap = 10
	$OscTextEdit._set_size(Vector2(w*2/3, h))
	$PostTextEdit._set_size(Vector2(w*1/3 - gap, h))
	$PostTextEdit._set_position(Vector2(w*2/3 + gap, 0))

	# $Letters.loadAlphabet([])


func evalCommandList(commands : Array, sender):
	while !commands.empty():
		var cmd = commands.pop_front()
		var addr : String = cmd[0]
		if addr[0] != '/':
			# Allow addresses missing the slash at start
			addr = addr.insert(0, '/')
		var args = cmd.slice(1, -1) if cmd.size() > 1 else []
		if addr == "/wait":
			var waitTime = $OscInterface.wait(args, sender)
			if waitTime:
				Logger.debug("Starting wait of %f seconds..." % [waitTime])
				yield(get_tree().create_timer(waitTime), "timeout")
				Logger.debug("...done waiting %f seconds" % [waitTime])
		else:
			var subCmds = evalOscCommand(addr, args, sender)
			if typeof(subCmds) == TYPE_ARRAY:
					commands = subCmds + commands


func evalOscCommand(address : String, args, sender):
	Logger.debug("+++ evalOscCommand(%s, %s" % [address, args])
	var applyToSelection = address.ends_with("!")
	if applyToSelection:
		address = address.trim_suffix("!")
		args.insert(0, "!")

	if actorCmds.has(address):
		actorCmds[address].call_func(args, sender)
	elif otherCmds.has(address):
		otherCmds[address].call_func(args, sender)
	elif $CustomCommands.hasCommand(address):
		var cmd = $CustomCommands.getCommand(address)
		if args.size() != cmd.args.size():
			$OscInterface.reportError("Custom command '%s' expects %d arguments"
					% [address, cmd.args.size()], sender)
			return
		var subCmds = []
		for subCmd in cmd.cmds:
			var subAddr = subCmd[0]
			Logger.debug("subCmd: (%s)%s" % [typeof(subCmd), subCmd])
			Logger.logDict($CustomCommands.commands)
			var subArgs = Array(subCmd).slice(1, -1) if subCmd.size() > 1 else []
			for i in range(subArgs.size()):
				if subArgs[i].begins_with("$"):
					var idx = cmd.args.find(subArgs[i].substr(1))
					if idx >= 0: subArgs[i] = args[idx]
			subCmds.push_back([subAddr] + subArgs)
			# Evaluation happens later, in the caller
		return subCmds
	else:
		$OscInterface.reportError("OSC command not found: " + address, sender)


func processOscMsg(address : String, args : Array, sender):
	evalCommandList([[address] + args], sender)


func _process(_delta):
	# check if there are pending messages
	while( oscrcv.has_message() ):
		# retrieval of the messages as a dictionary
		var msg = oscrcv.get_next()
		var sender = [msg["ip"], msg["port"]]
		if not $Config.allowRemoteClients and sender[0] != "127.0.0.1":
			Logger.warn("Skipping non-local OSC message from %s" % [sender])
			continue
		var address = msg["address"]
		var args = msg["args"]
		# printing the values, check console
		if false:
			Logger.debug( "address: %s" % [address] )
			Logger.debug( "typetag: %s" % [msg["typetag"]] )
			Logger.debug( "from: %s:%s" % [msg["ip"], msg["port"]] )
			Logger.debug( "arguments: ")
			for i in range( 0, msg["arg_num"] ):
				Logger.debug( "\t%s = %s" % [i, args[i]] )

		processOscMsg(address, args, sender)


func _exit_tree ( ):
	# disable the receiver, highly recommended!
	oscrcv.stop()

func _input(event):
#	Logger.debug(event.as_text())
	if event.is_action_pressed("toggle_editor", true):
		$OscTextEdit.set_visible(not($OscTextEdit.is_visible()))
	elif event.is_action_pressed("toggle_editor_and_post", true):
		$OscTextEdit.set_visible(not($OscTextEdit.is_visible()))
		$PostTextEdit.set_visible($OscTextEdit.is_visible())
	elif event.is_action_pressed("clear_post", true):
		$PostTextEdit.clear()
	elif event.is_action_pressed("toggle_post", true):
		$PostTextEdit.set_visible(not($PostTextEdit.is_visible()))
	elif event.is_action_pressed("post_commands", true):
		$OscTextEdit.set_visible(true)
		$PostTextEdit.set_visible($OscTextEdit.is_visible())
		$PostTextEdit.help()
		evalOscCommand("/list/commands", [], null)

func _on_OpenFileDialog_file_selected(path):
	openFile(path)

func openFile(path):
	var file = File.new()
	var err = file.open(path, File.READ)
	if err:
		if path.is_rel_path():
			var tryPath = OS.get_executable_path().get_base_dir() + "/" + path
			err = file.open(tryPath, File.READ)
			if err:
				Logger.error("can't open relative path as resource, or relative to executable (%s)" % [ProjectSettings.globalize_path(tryPath)])
		else:
			Logger.error("can't open absolute path: %s" % [ProjectSettings.globalize_path(path)])
	if !err:
		Logger.info("opened file: %s" % [path])
		$OscTextEdit.text = file.get_as_text()
	file.close()

func _on_SaveFileDialog_file_selected(path):
	saveFile(path)

func saveFile(path):
	Logger.info("save file to: %s" % [path])
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_string($OscTextEdit.text)
	file.close()

func post(msg):
	$PostTextEdit.append(msg)


