extends Node

var main
var animsNode

var metanode
var nodes

func _ready():
	main = get_parent()
	animsNode = main.get_node("Anims")

	nodes = {}
	metanode = preload("res://MetaNode.tscn")

	pass # Replace with function body.

func createAnim(args, sender):
	var nodeName = args[0]
	var animName = args[1]
	var newNode
	if nodes.has(nodeName):
		# replace animation if a node with this name exists
		newNode = nodes[nodeName]
	else:
		newNode = metanode.instance()
		animsNode.add_child(newNode)
		nodes[nodeName] = newNode
		newNode.position = Vector2(randf(), randf()) * main.get_viewport_rect().size
	newNode.get_node("Animation").play(animName)
	print("node: ", nodeName, newNode)
	print("anim: ", animName, newNode.get_node("Animation").get_animation())
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
	var pairs = {}
	for k in nodes.keys():
		pairs[k] = nodes[k].get_node("Animation").get_animation()
	print(pairs)
	sendMessage(sender, "/list/reply", pairs)
	pass

func reportError(errString, target):
	push_error(errString)
	sendMessage(target, "/error/reply", [errString])

func reportStatus(statusString, target):
	print(statusString)
	sendMessage(target, "/status/reply", [statusString])

func playAnim(args, sender):
	var nodeName = args[0]
	var animName = nodes[nodeName].get_node("Animation").get_animation()
	if nodes.has(nodeName):
		nodes[nodeName].get_node("Animation").play(animName)
	else:
		reportError("Node not found: " + nodeName, sender)
	pass

func stopAnim(args, sender):
	var nodeName = args[0]
	if nodes.has(nodeName):
		nodes[nodeName].get_node("Animation").stop()
	else:
		reportError("Node not found: " + nodeName, sender)
	pass
