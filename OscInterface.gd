extends Node

var main
var animsNode
var metanode

func _ready():
	main = get_parent()
	animsNode = main.get_node("Anims")

	metanode = preload("res://MetaNode.tscn")

	pass # Replace with function body.

func createAnim(args, sender):
	var nodeName = args[0]
	var animName = args[1]
	var newNode = animsNode.get_node(nodeName)
	if newNode == null:
		print("creating node '%s'" % [nodeName])
		newNode = metanode.instance()
		newNode.name = nodeName
		newNode.position = Vector2(randf(), randf()) * main.get_viewport_rect().size
		animsNode.add_child(newNode)
	newNode.get_node("Animation").play(animName)
	print("node: ", newNode.name)
	print("anim: ", newNode.get_node("Animation").get_animation())
	reportStatus("Created node '%s' width '%s'" % [newNode.name, newNode.get_node("Animation").get_animation()], sender)
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

func listAnims(sender):
	var pairs = {}
	for a in animsNode.get_children():
		pairs[a.name] = a.get_node("Animation").get_animation()
	print(pairs)
	sendMessage(sender, "/list/reply", pairs)
	pass

func reportError(errString, target):
	push_error(errString)
	sendMessage(target, "/error/reply", [errString])

func reportStatus(statusString, target):
	print(statusString)
	sendMessage(target, "/status/reply", [statusString])

func getNode(nodeName, sender):
	var node = animsNode.get_node(nodeName)
	if node != null:
		return node
	else:
		reportError("Node not found: " + nodeName, sender)
		return false

func playAnim(args, sender):
	var node = getNode(args[0], sender)
	if node:
		var animName = node.get_node("Animation").get_animation()
		node.get_node("Animation").play(animName)
	pass

func stopAnim(args, sender):
	var node = getNode(args[0], sender)
	if node:
		node.get_node("Animation").stop()
	pass

func setAnimPosition(args, sender):
	var node = getNode(args[0], sender)
	if node:
		var w = ProjectSettings.get_setting("display/window/size/width") * args[1]
		var h = ProjectSettings.get_setting("display/window/size/height") * args[2]
		node.set_position(Vector2(w,h))
	pass

func setAnimSpeed(args, sender):
	var node = getNode(args[0], sender)
	if node:
		node.get_node("Animation").set_speed_scale(args[1])
	pass

func setAnimFrame(args, sender):
	var node = getNode(args[0], sender)
	if node:
		node.get_node("Animation").set_frame(args[1])

func flipAnimV(args, sender):
	var node = getNode(args[0], sender)
	if node:
		var anim = node.get_node("Animation")
		anim.set_flip_v(not(anim.is_flipped_v()))

func flipAnimH(args, sender):
	var node = getNode(args[0], sender)
	if node:
		var anim = node.get_node("Animation")
		anim.set_flip_h(not(anim.is_flipped_h()))

func selectAnim(args, sender):
	# add_to_group("selected")
	reportError("TODO", sender)
	pass

func deselectAnim(args, sender):
	# remove_from_group("selected")
	reportError("TODO", sender)
	pass

func listSelectedAnims(sender):
	# reportStatus("selected: " + get_tree().get_nodes_in_group(selected), sender)
	reportError("TODO", sender)
	pass
