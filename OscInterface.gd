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
	reportStatus("Created node '%s' with '%s'" % [newNode.name, newNode.get_node("Animation").get_animation()], sender)

func freeAnim(inArgs, sender):
	var args = getOptionalSelectionArgs(inArgs, "freeAnim", 0, sender)
	if args: for node in args.nodes:
		animsNode.remove_child(node)
		reportStatus("Freed: " + String(getNames(args.nodes)), sender)

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

func listAnims(args, sender):
	if !args.empty():
		reportError("listAnims expects no arguments", sender)
		return
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
	if matches.empty(): matches = get_tree().get_nodes_in_group(nameWildcard)
	if matches.empty():
		reportError("No matches found for: " + String(nameWildcard), sender)
	else:
		print("Matched: ", getNames(matches))
	return matches

func getOptionalSelectionArgs(inArgs, methodName, expectedArgs, sender):
	if inArgs.size() == expectedArgs:
			return { nodes = get_tree().get_nodes_in_group(selectionGroup), args = inArgs }
	elif inArgs.size() == expectedArgs + 1:
			return { nodes = matchNodes(inArgs[0], sender), args = [] if inArgs.size() < 2 else inArgs.slice(1, -1) }
	else:
		reportError(methodName + ": unexpected number of arguments: " + String(inArgs.size()) + " instead of " + String(expectedArgs), sender)
		return
	
func playAnim(inArgs, sender):
	var args = getOptionalSelectionArgs(inArgs, "playAnim", 0, sender)
	if args: for node in args.nodes:
		var animName = node.get_node("Animation").get_animation()
		node.get_node("Animation").play(animName)

func stopAnim(inArgs, sender):
	var args = getOptionalSelectionArgs(inArgs, "stopAnim", 0, sender)
	if args: for node in args.nodes:
		node.get_node("Animation").stop()

func setAnimPosition(inArgs, sender):
	var args = getOptionalSelectionArgs(inArgs, "setAnimPosition", 2, sender)
	if args:
		var viewSize = Vector2(
			ProjectSettings.get_setting("display/window/size/width"),
			ProjectSettings.get_setting("display/window/size/height")
		)
		for node in args.nodes:
			node.set_position(viewSize * Vector2(args.args[0], args.args[1]))

func setAnimSpeed(inArgs, sender):
	var args = getOptionalSelectionArgs(inArgs, "setAnimSpeed", 1, sender)
	if args: for node in args.nodes:
		node.get_node("Animation").set_speed_scale(args.args[0])

func setAnimFrame(inArgs, sender):
	var args = getOptionalSelectionArgs(inArgs, "setAnimFrame", 1, sender)
	if args: for node in args.nodes:
		node.get_node("Animation").set_frame(args.args[0])

func flipAnimV(inArgs, sender):
	var args = getOptionalSelectionArgs(inArgs, "flipAnimV", 0, sender)
	if args: for node in args.nodes:
		var anim = node.get_node("Animation")
		anim.set_flip_v(not(anim.is_flipped_v()))

func flipAnimH(inArgs, sender):
	var args = getOptionalSelectionArgs(inArgs, "flipAnimH", 0, sender)
	if args: for node in args.nodes:
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
	if args.empty():
		listSelectedAnims(args, sender)
	else:
		for node in matchNodes(args[0], sender):
			node.add_to_group(selectionGroup)
			setShaderUniform(node, "uSelected", true)

func deselectAnim(args, sender):
	for node in matchNodes(args[0], sender):
		node.remove_from_group(selectionGroup)
		setShaderUniform(node, "uSelected", false)

func listSelectedAnims(args, sender):
	if !args.empty():
		reportError("listSelectedAnims expects no arguments", sender)
		return
	var nodes = get_tree().get_nodes_in_group(selectionGroup)
	reportStatus("selected: " + String(getNames(nodes)), sender)

func colorAnim(inArgs, sender):
	var args = getOptionalSelectionArgs(inArgs, "colorAnim", 3, sender)
	if args:
		var rgb = Vector3(args.args[0], args.args[1], args.args[2])
		for node in args.nodes:
			setShaderUniform(node, "uAddColor", rgb)

func setShaderUniform(node, uName, uValue):
	var image = node.get_node("Animation")
	image.material.set_shader_param(uName, uValue)
