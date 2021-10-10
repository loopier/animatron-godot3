extends Node2D

var oscrcv

func _ready():
	randomize()
		
	# See: https://gitlab.com/frankiezafe/gdosc
	oscrcv = load("res://addons/gdosc/gdoscreceiver.gdns").new()
	# [optional] maximum number of messages in the buffer, default is 100
	oscrcv.max_queue( 20 )
	# [optional]  receiver will only keeps the "latest" message for each address
	oscrcv.avoid_duplicate( true )
	# [mandatory] listening to port 14000
	oscrcv.setup( 56101 )
	# [mandatory] starting the reception of messages
	oscrcv.start()
			
func processOscMsg(address, args, msg):
	var animArgs = [] if args.empty() else [args[0]]
	var cmds = {
		"/list": funcref($OscInterface, "listAnims"),
		"/play": funcref($OscInterface, "playAnim"),
		"/stop": funcref($OscInterface, "stopAnim"),
		"/create": funcref($OscInterface, "createAnim"),
		"/free": funcref($OscInterface, "freeAnim"),
		"/select": funcref($OscInterface, "selectAnim"),
		"/deselect": funcref($OscInterface, "deselectAnim"),
		"/selected": funcref($OscInterface, "listSelectedAnims"),
		}

	var sender = [msg["ip"], msg["port"]]
	if cmds.has(address):
		if args.empty():
			cmds[address].call_func(sender)
		else:
			cmds[address].call_func(args, sender)
	else:
		$OscInterface.reportError("OSC command not found: " + address, sender)

func _process(delta):
	
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
	pass
	
func _exit_tree ( ):
	# disable the receiver, highly recommended!
	oscrcv.stop()
