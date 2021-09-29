extends Node2D

var oscrcv
var anims

func _ready():
	anims = {
		"runner": [get_node("KinematicBody2D/AnimatedSprite"), "run"],
		"frog": [get_node("KinematicBody2D2/AnimatedSprite"), ""],
		"fox": [get_node("KinematicBody2D3/AnimationPlayer"), "walk"]
		}
	
	oscrcv = load("res://addons/gdosc/gdoscreceiver.gdns").new()
	# [optional] maximum number of messages in the buffer, default is 100
	oscrcv.max_queue( 20 )
	# [optional]  receiver will only keeps the "latest" message for each address
	oscrcv.avoid_duplicate( true )
	# [mandatory] listening to port 14000
	oscrcv.setup( 56101 )
	# [mandatory] starting the reception of messages
	oscrcv.start()

func processOscMsg(address, args):
	var entry = anims.get(args[0])

	if entry == null:
		print("Unknown OSC command: " + address)
		pass

	var target = entry[0]
	if target == null:
		print("Unknown play target: " + args[0])
		pass

	var cmds = {
		"/play": funcref(target, "play"),
		"/stop": funcref(target, "stop")
		}

	print("target:", target, " args: ", entry[1])
	cmds[address].call_func()

func _process(delta):
	
	# check if there are pending messages
	while( oscrcv.has_message() ):
		# retrieval of the messages as a dictionary
		var msg = oscrcv.get_next()
		var address = msg["address"]
		var args = msg["args"]
		# printing the values, check console
		print( "address:", address )
		print( "typetag:", msg["typetag"] )
		print( "from:" + str( msg["ip"] ) + ":" + str( msg["port"] ) )
		print( "arguments: ")
		for i in range( 0, msg["arg_num"] ):
			print( "\t", i, " = ", args[i] )

		processOscMsg(address, args)
	pass
	
func _exit_tree ( ):
	# disable the receiver, highly recommended!
	oscrcv.stop()
