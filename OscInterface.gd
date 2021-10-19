extends Node

var main
var animsNode
var metanode
var speechBubbleNode
var runtimeLoadedFrames
const selectionGroup = "selected"

func _ready():
	main = get_parent()
	animsNode = main.get_node("Anims")
	metanode = preload("res://MetaNode.tscn")
	speechBubbleNode = preload("res://SpeechBubble.tscn")
	runtimeLoadedFrames = loadRuntimeAnimations("res://animations/")

############################################################
# Helpers
############################################################
func getRuntimeSpriteFiles(path):
	var dir = Directory.new()
	var files = []
	if dir.open(path) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		while (!file_name.empty() && !dir.current_is_dir()):
			print("File name: ", file_name)  # Debugging release builds
			if file_name.ends_with(".png") || file_name.ends_with(".jpg"):
				files.push_back(path + file_name)
			file_name = dir.get_next()
	return files

func getExternalTexture(path):
	var img = Image.new()
	img.load(path)
	var texture = ImageTexture.new()
	# We don't want interpolation or repeats here
	texture.create_from_image(img, Texture.FLAG_MIPMAPS)
	return texture

func getSpriteFileInfo(name):
	var dict = {}
	var regex = RegEx.new()
	regex.compile("(.+)_(\\d+)x(\\d+)_(\\d+)fps")
	var result = regex.search(name)
	if result:
		print(result.get_string()) # Would print n-0123
		dict.name = result.get_string(1)
		dict.xStep = result.get_string(2).to_int()
		dict.yStep = result.get_string(3).to_int()
		dict.fps = result.get_string(4).to_int()
		print(dict)
	else:
		dict.name = name
		dict.xStep = 4
		dict.yStep = 4
		dict.fps = 24
	return dict
	
func loadRuntimeAnimations(path):
	var sprites = getRuntimeSpriteFiles(path)
	print("Runtime sprites:", sprites)
	# Add the runtime-loaded sprites to our pre-existing library
	var frames = metanode.instance().get_node("Animation").frames
	for spritePath in sprites:
		var res
		# res = load(spritePath)
		if !res: res = getExternalTexture(spritePath)
		if res:
			var info = getSpriteFileInfo(spritePath.get_file().get_basename())
			frames.remove_animation(info.name)
			frames.add_animation(info.name)
			frames.set_animation_speed(info.name, info.fps)
			var width = res.get_size().x / info.xStep
			var height = res.get_size().y / info.yStep
			var frameId = 0
			for y in range(0, info.yStep):
				for x in range(0, info.xStep):
					var texture : AtlasTexture = AtlasTexture.new()
					texture.atlas = res
					texture.region = Rect2(width * x, height * y, width, height)
					texture.margin = Rect2(0, 0, 0, 0)
					frames.add_frame(info.name, texture, frameId)
					frameId += 1
	return frames

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
	if nameWildcard == "!":
		# Match the current selected set
		return get_tree().get_nodes_in_group(selectionGroup)

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

# expectedArgs refers to the number of expected arguments
# *not* including the first (target) argument. It can be an
# integer or an array of two values (min/max number of allowed
# arguments).
func getActorsAndArgs(inArgs, methodName, expectedArgs, sender):
	if typeof(expectedArgs) == TYPE_INT: expectedArgs = [expectedArgs]
	if inArgs.size() > expectedArgs.front() && inArgs.size() <= expectedArgs.back() + 1:
		return { actors = matchNodes(inArgs[0], sender), args = inArgs.slice(1, -1) }
	else:
		reportError(methodName + ": unexpected number of arguments: " + String(inArgs.size()) + " instead of target plus " + String(expectedArgs), sender)
		return

func setShaderUniform(node, uName, uValue):
	var image = node.get_node("Animation")
	image.material.set_shader_param(uName, uValue)

############################################################
# OSC "other" commands
############################################################

func createAnim(args, sender):
	var nodeName = args[0]
	var animName = args[1]
	if !runtimeLoadedFrames.has_animation(animName):
		reportError("Anim type not found: '%s'" % animName, sender)
		return
	var newNode = animsNode.get_node(nodeName)
	if newNode == null:
		print("creating node '%s'" % [nodeName])
		newNode = metanode.instance()
		newNode.name = nodeName
		newNode.position = Vector2(randf(), randf()) * main.get_viewport_rect().size
		# Switch to the animation library that includes runtime-loaded data
		newNode.get_node("Animation").frames = runtimeLoadedFrames
		animsNode.add_child(newNode)

	var animNode = newNode.get_node("Animation")
	animNode.play(animName)
	# Set the offset of the child sprite so the MetaNode centre is near
	# its bottom (the "feet"). In future, this could be set differently
	# for each anim as metadata, but for now this is okay.
	var anim = animNode.get_animation()
	var texSize = animNode.frames.get_frame(animName, 0).get_size()
	animNode.position = Vector2(0, texSize.y * -0.45)
	
	print("node: ", newNode.name)
	print("anim: ", anim)
	reportStatus("Created node '%s' with '%s'" % [newNode.name, anim], sender)

# List the instantiated actors
func listActors(args, sender):
	if !args.empty():
		reportError("listActors expects no arguments", sender)
		return
	var pairs = {}
	for a in animsNode.get_children():
		pairs[a.name] = a.get_node("Animation").get_animation()
	print(pairs)
	sendMessage(sender, "/list/actors/reply", pairs)

# List the loaded and available animations (or images)
func listAnims(args, sender):
	if !args.empty():
		reportError("listAnims expects no arguments", sender)
		return
	var names = []
	for a in runtimeLoadedFrames.get_animation_names():
		names.push_back(a)
	print(names)
	sendMessage(sender, "/list/anims/reply", names)

# List the assets/files on disk
func listAssets(args, sender):
	# TODO
	if !args.empty():
		reportError("listAssets expects no arguments", sender)
		return
	var names = ["example", "assets", "(TODO)"]
#	for a in runtimeLoadedFrames.get_animation_names():
#		names.push_back(a)
	print(names)
	sendMessage(sender, "/list/assets/reply", names)

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
	if args.empty(): args = ["*"];
	for node in matchNodes(args[0], sender):
		node.remove_from_group(selectionGroup)
		setShaderUniform(node, "uSelected", false)

func listSelectedAnims(args, sender):
	if !args.empty():
		reportError("listSelectedAnims expects no arguments", sender)
		return
	var nodes = get_tree().get_nodes_in_group(selectionGroup)
	reportStatus("selected: " + String(getNames(nodes)), sender)


############################################################
# OSC Actor commands
#   The first argument for all these commands is the target actor(s).
#   It may be "!" (selection), an actor instance name or a wildcard string.
############################################################

func freeAnim(inArgs, sender):
	var args = getActorsAndArgs(inArgs, "freeAnim", 0, sender)
	if args: for node in args.actors:
		animsNode.remove_child(node)
	reportStatus("Freed: " + String([] if !args else getNames(args.actors)), sender)

func playAnim(inArgs, sender):
	var args = getActorsAndArgs(inArgs, "playAnim", 0, sender)
	if args: for node in args.actors:
		var animName = node.get_node("Animation").get_animation()
		node.get_node("Animation").play(animName)

func stopAnim(inArgs, sender):
	var args = getActorsAndArgs(inArgs, "stopAnim", 0, sender)
	if args: for node in args.actors:
		node.get_node("Animation").stop()

func setAnimFrame(inArgs, sender):
	var args = getActorsAndArgs(inArgs, "setAnimFrame", 1, sender)
	if args: for node in args.actors:
		node.get_node("Animation").set_frame(args.args[0])

func setAnimPosition(inArgs, sender):
	var args = getActorsAndArgs(inArgs, "setAnimPosition", [2, 3], sender)
	if args:
		var viewSize = Vector2(
			ProjectSettings.get_setting("display/window/size/width"),
			ProjectSettings.get_setting("display/window/size/height")
		)
		var dur = 0 if args.args.size() == 2 else args.args[2]
		for node in args.actors:
			var tween = node.get_node("Tween")
			tween.interpolate_property(node, "position",
				node.position,
				viewSize * Vector2(args.args[0], args.args[1]),
				dur,
				Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			tween.start()

func setAnimSpeed(inArgs, sender):
	var args = getActorsAndArgs(inArgs, "setAnimSpeed", 1, sender)
	if args: for node in args.actors:
		node.get_node("Animation").set_speed_scale(args.args[0])

func flipAnimH(inArgs, sender):
	var args = getActorsAndArgs(inArgs, "flipAnimH", 0, sender)
	if args: for node in args.actors:
		var anim = node.get_node("Animation")
		anim.set_flip_h(not(anim.is_flipped_h()))

func flipAnimV(inArgs, sender):
	var args = getActorsAndArgs(inArgs, "flipAnimV", 0, sender)
	if args: for node in args.actors:
		var anim = node.get_node("Animation")
		anim.set_flip_v(not(anim.is_flipped_v()))

func colorAnim(inArgs, sender):
	var args = getActorsAndArgs(inArgs, "colorAnim", 3, sender)
	if args:
		var rgb = Vector3(args.args[0], args.args[1], args.args[2])
		for node in args.actors:
			setShaderUniform(node, "uAddColor", rgb)

func sayAnim(inArgs, sender):
	var aa = getActorsAndArgs(inArgs, "sayAnim", [1, 2], sender)
	if aa:
		for node in aa.actors:
			var msg = String(aa.args[0])
			var bubble = speechBubbleNode.instance()
			node.add_child(bubble)
			if len(aa.args) == 2:
				bubble.setText(msg, aa.args[1])
			else:
				bubble.setText(msg)