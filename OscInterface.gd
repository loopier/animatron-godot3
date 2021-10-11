extends Node

var main
var animsNode
var metanode
const selectionGroup = "selected"

func _ready():
	main = get_parent()
	animsNode = main.get_node("Anims")
	metanode = preload("res://MetaNode.tscn")

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

func freeAnim(args, sender):
	var objName = args[0]
	var matches = matchNodes(objName, sender)
	for m in matches:
		animsNode.remove_child(m)
	reportStatus("Freed: " + String(getNames(matches)), sender)

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

func listAnims(sender):
	var pairs = {}
	for a in animsNode.get_children():
		pairs[a.name] = a.get_node("Animation").get_animation()
	print(pairs)
	sendMessage(sender, "/list/reply", pairs)

func reportError(errString, target):
	push_error(errString)
	sendMessage(target, "/error/reply", [errString])

func reportStatus(statusString, target):
	print(statusString)
	sendMessage(target, "/status/reply", [statusString])

func getNode(nodeName, sender):
	var node = animsNode.find_node(nodeName, true, false)
	if node:
		return node
	else:
		reportError("Node not found: " + nodeName, sender)
		return false

func getNames(objList):
	var names = []
	for o in objList: names.push_back(o.name)
	return names

func matchNodes(nameWildcard, sender):
	var matches = []
	for a in animsNode.get_children():
		if a.name.match(nameWildcard):
			matches.push_back(a)
	if matches.empty():
		reportError("No matches found for: " + nameWildcard, sender)
	else:
		print("Matched: ", getNames(matches))
	return matches

func playAnim(args, sender):
	for node in matchNodes(args[0], sender):
		var animName = node.get_node("Animation").get_animation()
		node.get_node("Animation").play(animName)

func stopAnim(args, sender):
	for node in matchNodes(args[0], sender):
		node.get_node("Animation").stop()

func setAnimPosition(args, sender):
	for node in matchNodes(args[0], sender):
		var w = ProjectSettings.get_setting("display/window/size/width") * args[1]
		var h = ProjectSettings.get_setting("display/window/size/height") * args[2]
		node.set_position(Vector2(w,h))

func setAnimSpeed(args, sender):
	for node in matchNodes(args[0], sender):
		node.get_node("Animation").set_speed_scale(args[1])

func setAnimFrame(args, sender):
	for node in matchNodes(args[0], sender):
		node.get_node("Animation").set_frame(args[1])

func flipAnimV(args, sender):
	for node in matchNodes(args[0], sender):
		var anim = node.get_node("Animation")
		anim.set_flip_v(not(anim.is_flipped_v()))

func flipAnimH(args, sender):
	for node in matchNodes(args[0], sender):
		var anim = node.get_node("Animation")
		anim.set_flip_h(not(anim.is_flipped_h()))

func groupAnim(args, sender):
	var groupName = args[0]
	if args.size() == 1:
		# With no other arguments, just list the members
		var members = get_tree().get_nodes_in_group(groupName)
		reportStatus("'" + groupName + "' members: " + String(getNames(members)), sender)
	else:
		for node in matchNodes(args[1], sender):
			node.add_to_group(groupName)
	
func ungroupAnim(args, sender):
	var groupName = args[0]
	for node in matchNodes(args[1], sender):
		node.remove_from_group(groupName)
	
func selectAnim(args, sender):
	for node in matchNodes(args[0], sender):
		node.add_to_group(selectionGroup)

func deselectAnim(args, sender):
	for node in matchNodes(args[0], sender):
		node.remove_from_group(selectionGroup)

func listSelectedAnims(sender):
	var nodes = get_tree().get_nodes_in_group(selectionGroup)
	reportStatus("selected: " + String(getNames(nodes)), sender)
