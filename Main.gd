extends Node2D

var oscrcv

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
			
func processOscMsg(address, args, msg):
	# Actor commands:
	#   The first argument for all these commands is the target actor(s).
	#   It may be "!" (selection), an actor instance name or a wildcard string.
	var actorCmds = {
		"/free": funcref($OscInterface, "freeActor"),
		"/play": funcref($OscInterface, "playActor"),
		"/stop": funcref($OscInterface, "stopActor"),
		"/frame": funcref($OscInterface, "setActorFrame"),
		"/position": funcref($OscInterface, "setActorPosition"),
		"/speed": funcref($OscInterface, "setActorSpeed"),
		"/fliph": funcref($OscInterface, "flipActorH"),
		"/flipv": funcref($OscInterface, "flipActorV"),
		"/color": funcref($OscInterface, "colorActor"),
		"/say": funcref($OscInterface, "sayActor"),
	}
	
	var otherCmds = {
		"/create": funcref($OscInterface, "createActor"),
		"/list": funcref($OscInterface, "listActors"), # shortcut for /list/actors
		"/list/actors": funcref($OscInterface, "listActors"),
		"/list/anims": funcref($OscInterface, "listAnims"),
		"/list/assets": funcref($OscInterface, "listAssets"),
		"/group": funcref($OscInterface, "groupActor"),
		"/ungroup": funcref($OscInterface, "ungroupActor"),
		"/select": funcref($OscInterface, "selectActor"),
		"/deselect": funcref($OscInterface, "deselectActor"),
		"/selected": funcref($OscInterface, "listSelectedActors"),
	}

	var sender = [msg["ip"], msg["port"]]

	var applyToSelection = address.ends_with("!")
	if applyToSelection:
		address = address.trim_suffix("!")
		args.insert(0, "!")

	if actorCmds.has(address):
		actorCmds[address].call_func(args, sender)
	elif otherCmds.has(address):
		otherCmds[address].call_func(args, sender)
	else:
		$OscInterface.reportError("OSC command not found: " + address, sender)

func _process(_delta):
	# check if there are pending messages
	while( oscrcv.has_message() ):
		# retrieval of the messages as a dictionary
		var msg = oscrcv.get_next()
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

		processOscMsg(address, args, msg)
	
func _exit_tree ( ):
	# disable the receiver, highly recommended!
	oscrcv.stop()
