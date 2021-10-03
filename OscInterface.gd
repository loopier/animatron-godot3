extends Node

var main
var animsNode
var animScenes

func _ready():
	main = get_parent()
	animsNode = main.get_node("Anims")

	animScenes = {
		"runner": [preload("res://Runner.tscn"), "run"],
		"frog": [preload("res://Frog.tscn"), "jump"],
		"fox": [preload("res://Fox.tscn"), "walk"],
	}

	pass # Replace with function body.

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
	animsNode.add_child(anim)
	anim.position = Vector2(randf(), randf()) * main.get_viewport_rect().size
	anim.get_node("Animation").play(animName)
	pass

func freeAnim(args, sender):
	var objName = args[0]
	var matches = []
	for a in animsNode.get_children():
		if a.name.match(objName):
			matches.push_back(a.name)
	if !matches.empty(): print("Matches: ", matches)
	else: print("No matches...")
	for m in matches:
		animsNode.remove_child(animsNode.get_node(m))
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
	for a in animsNode.get_children():
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
	var node = animsNode.get_node(objName)
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
	var node = animsNode.get_node(objName)
	if node:
		var anim = node.get_node("Animation")
		if anim: anim.stop()
	else:
		reportError("Stop anim not found: " + objName, sender)
		pass
