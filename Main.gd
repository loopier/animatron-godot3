extends Node2D

var oscrcv
var animScenes

func _ready():
	randomize()
	
	animScenes = {
		"runner": [preload("res://Runner.tscn"), "run"],
		"frog": [preload("res://Frog.tscn"), "jump"],
		"fox": [preload("res://Fox.tscn"), "walk"],
	}
	
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

func createAnim(args, sender):
	var sceneName = args[0]
	var entry = animScenes.get(sceneName)
	if entry == null:
		print("Unknown animation type to create: " + sceneName)
		pass
	
	var scene = entry[0]
	var animName = entry[1]
	var anim = scene.instance()
	anim.name = sceneName
	$Anims.add_child(anim)
	anim.position = Vector2(randf(), randf()) * get_viewport_rect().size
	anim.get_node("Animation").play(animName)
	pass

func freeAnim(args, sender):
	var objName = args[0]
	var matches = []
	for a in $Anims.get_children():
		if a.name.match(objName):
			matches.push_back(a.name)
	if !matches.empty(): print("Matches: ", matches)
	else: print("No matches...")
	for m in matches:
		$Anims.remove_child($Anims.get_node(m))
	reportStatus("Freed: " + String(matches), sender)
	pass
	
# For now, it just creates a sender instance each call,
# so isn't designed for continuous/heavy use...
func sendMessage(target, oscAddress, oscArgs):
	var oscsnd = load("res://addons/gdosc/gdoscsender.gdns").new()
	var ip = target[0]
	var port = target[1]
	oscsnd.setup(ip, port)
	oscsnd.start()
	oscsnd.msg(oscAddress)
	for arg in oscArgs:
		oscsnd.add(arg)
	oscsnd.send()
	oscsnd.stop()
	pass

func listAnims(args, sender):
	#print_tree()
	var childNames = []
	for a in $Anims.get_children():
		childNames.push_back(a.name)
	if !childNames.empty(): print("Anims: ", childNames)
	else: print("No anims...")
	sendMessage(sender, "/list/reply", childNames)
	pass

func reportError(errString, target):
	push_error(errString)
	sendMessage(target, "/error/reply", [errString])

func reportStatus(statusString, target):
	print(statusString)
	sendMessage(target, "/status/reply", [statusString])

func playAnim(args, sender):
	var objName = args[0]
	var node = $Anims.get_node(objName)
	if node:
		var nodePath = node.filename
		for a in animScenes:
			var scenePath = animScenes[a][0].resource_path
			if scenePath == nodePath:
				var animName = animScenes[a][1]
				var anim = node.get_node("Animation")
				if anim: anim.play(animName)
				break
	else:
		reportError("Play anim not found: " + objName, sender)
		pass

func stopAnim(args, sender):
	var objName = args[0]
	var node = $Anims.get_node(objName)
	if node:
		var anim = node.get_node("Animation")
		if anim: anim.stop()
	else:
		reportError("Stop anim not found: " + objName, sender)
		pass
		
func processOscMsg(address, args, msg):
	var animArgs = [] if args.empty() else [args[0]]
	var cmds = {
		"/list": funcref(self, "listAnims"),
		"/play": funcref(self, "playAnim"),
		"/stop": funcref(self, "stopAnim"),
		"/create": funcref(self, "createAnim"),
		"/free": funcref(self, "freeAnim"),
		}

	var sender = [msg["ip"], msg["port"]]
	if cmds.has(address):
		cmds[address].call_func(args, sender)
	else:
		reportError("OSC command not found: " + address, sender)

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
