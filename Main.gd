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
	var cmds = {
		"/create": funcref($OscInterface, "createAnim"),
		"/free": funcref($OscInterface, "freeAnim"),
		"/list": funcref($OscInterface, "listActors"), # shortcut for /list/actors
		"/list/actors": funcref($OscInterface, "listActors"),
		"/list/anims": funcref($OscInterface, "listAnims"),
		"/list/assets": funcref($OscInterface, "listAssets"),
		"/play": funcref($OscInterface, "playAnim"),
		"/stop": funcref($OscInterface, "stopAnim"),
		"/frame": funcref($OscInterface, "setAnimFrame"),
		"/position": funcref($OscInterface, "setAnimPosition"),
		"/speed": funcref($OscInterface, "setAnimSpeed"),
		"/fliph": funcref($OscInterface, "flipAnimH"),
		"/flipv": funcref($OscInterface, "flipAnimV"),
		"/color": funcref($OscInterface, "colorAnim"),
		"/say": funcref($OscInterface, "sayAnim"),
		"/group": funcref($OscInterface, "groupAnim"),
		"/ungroup": funcref($OscInterface, "ungroupAnim"),
		"/select": funcref($OscInterface, "selectAnim"),
		"/deselect": funcref($OscInterface, "deselectAnim"),
		"/selected": funcref($OscInterface, "listSelectedAnims"),
	}

	var sender = [msg["ip"], msg["port"]]
	if cmds.has(address):
		cmds[address].call_func(args, sender)
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
