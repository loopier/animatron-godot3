extends Node2D

var oscrcv
# Actor commands:
#   The first argument for all these commands is the target actor(s).
#   It may be "!" (selection), an actor instance name or a wildcard string.
onready var actorCmds = {
	"/free": funcref($OscInterface, "freeActor"),
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
	"/loop": funcref($OscInterface, "setActorLoop"),
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
	# "/wait" command is handled specially 

	# write
	"/load/alphabet": funcref($Letters, "loadAlphabet"),
	"/write": funcref($Letters, "write"),
	"/letter": funcref($Letters, "setLetter"),
	"/letters/spacing": funcref($Letters, "setSpacing"),
	"/letters/scale": funcref($Letters, "setScale"),

	# app
	"/list/commands": funcref($OscInterface, "listCommands"),

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
				if $OscInterface.allowStatusReport:
					print("Starting wait of %f seconds..." % [waitTime])
				yield(get_tree().create_timer(waitTime), "timeout")
				if $OscInterface.allowStatusReport:
					print("...done waiting %f seconds" % [waitTime])
		else:
			var subCmds = evalOscCommand(addr, args, sender)
			if typeof(subCmds) == TYPE_ARRAY:
					commands = subCmds + commands


func evalOscCommand(address : String, args, sender):
	if $OscInterface.allowStatusReport:
		print("+++ evalOscCommand(", address, ", ", String(args), ")")
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
			print("Skipping non-local OSC message from ", sender)
			continue
		var address = msg["address"]
		var args = msg["args"]
		# printing the values, check console
		if false:
			print( "address:", address )
			print( "typetag:", msg["typetag"] )
			print( "from:" + str( msg["ip"] ) + ":" + str( msg["port"] ) )
			print( "arguments: ")
			for i in range( 0, msg["arg_num"] ):
				print( "\t", i, " = ", args[i] )

		processOscMsg(address, args, sender)


func _exit_tree ( ):
	# disable the receiver, highly recommended!
	oscrcv.stop()
