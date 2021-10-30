extends Node

onready var main = get_parent()
onready var actorsNode = main.get_node("Actors")
onready var customCmds : CustomCommands = main.get_node("CustomCommands")
onready var metanode = preload("res://MetaNode.tscn")
onready var speechBubbleNode = preload("res://SpeechBubble.tscn")
var animFramesLibrary
var spriteFilenameRegex
var sequenceFilenameRegex
const animationAssetPath = "res://animations/"
const selectionGroup = "selected"
const loadAllAssetsAtStartup = false

func _ready():
	spriteFilenameRegex = RegEx.new()
	spriteFilenameRegex.compile("(.+)_(\\d+)x(\\d+)_(\\d+)fps")
	sequenceFilenameRegex = RegEx.new()
	sequenceFilenameRegex.compile("(.+)_(\\d+)fps")

	animFramesLibrary = metanode.instance().get_node("Animation").frames
	if loadAllAssetsAtStartup:
		var assets = getAssetFilesMatching(animationAssetPath, "*")
		loadSprites(assets.sprites)
		loadSequences(assets.seqs)


############################################################
# Helpers
############################################################
func getAssetBaseName(fileName):
	var baseName = fileName.get_basename()
	var split = baseName.split("_", false, 1)
	if !split.empty(): baseName = split[0]
	return baseName


func getAnimSequenceFrames(path):
	var dir = Directory.new()
	var frames = []
	if dir.open(path) == OK:
		dir.list_dir_begin(true, true)
		var filename = dir.get_next()
		while !filename.empty() and !dir.current_is_dir():
			if filename.ends_with(".png") or filename.ends_with(".jpg"):
				frames.push_back(filename)
			filename = dir.get_next()
	return frames


func getAssetFilesMatching(path, nameWildcard):
	var dir = Directory.new()
	var files = { sprites = [], seqs = [] }
	if dir.open(path) == OK:
		dir.list_dir_begin(true, true)
		var filename = dir.get_next()
		while !filename.empty():
			if dir.current_is_dir():
				var baseFile = getAssetBaseName(filename)
				if baseFile.match(nameWildcard):
					var seqFrames = getAnimSequenceFrames(path + filename);
					if !seqFrames.empty():
						print("Sequence (%d frames) file name: %s" % [seqFrames.size(), filename])
						files.seqs.push_back(path + filename)
			elif filename.ends_with(".png") or filename.ends_with(".jpg"):
				var baseFile = getAssetBaseName(filename)
				if baseFile.match(nameWildcard):
					print("File name: ", filename)
					files.sprites.push_back(path + filename)
			filename = dir.get_next()
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
	var result = spriteFilenameRegex.search(name)
	if result:
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


func getSeqFileInfo(name):
	var dict = {}
	var result = sequenceFilenameRegex.search(name)
	if result:
		dict.name = result.get_string(1)
		dict.fps = result.get_string(2).to_int()
		print(dict)
	else:
		dict.name = name
		dict.fps = 24
	return dict


func loadSprites(sprites):
	print("Runtime sprites:", sprites)
	# Add the runtime-loaded sprites to our pre-existing library
	for spritePath in sprites:
		var res
		# res = load(spritePath)
		if !res: res = getExternalTexture(spritePath)
		if res:
			var info = getSpriteFileInfo(spritePath.get_file().get_basename())
			animFramesLibrary.remove_animation(info.name)
			animFramesLibrary.add_animation(info.name)
			animFramesLibrary.set_animation_speed(info.name, info.fps)
			var width = res.get_size().x / info.xStep
			var height = res.get_size().y / info.yStep
			var frameId = 0
			for y in range(0, info.yStep):
				for x in range(0, info.xStep):
					var texture : AtlasTexture = AtlasTexture.new()
					texture.atlas = res
					texture.region = Rect2(width * x, height * y, width, height)
					texture.margin = Rect2(0, 0, 0, 0)
					animFramesLibrary.add_frame(info.name, texture, frameId)
					frameId += 1


func loadSequences(sequences):
	print("Runtime sequences:", sequences)
	# Add the runtime-loaded image sequences to our pre-existing library
	for seqPath in sequences:
		var info = getSeqFileInfo(seqPath.get_file().get_basename())
		animFramesLibrary.remove_animation(info.name)
		animFramesLibrary.add_animation(info.name)
		animFramesLibrary.set_animation_speed(info.name, info.fps)
		var frameId = 0
		for img in getAnimSequenceFrames(seqPath):
			var texture = getExternalTexture(seqPath + "/" + img)
			if texture:
				var width = texture.get_size().x
				var height = texture.get_size().y
				animFramesLibrary.add_frame(info.name, texture, frameId)
				frameId += 1


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
	var node = actorsNode.find_node(nodeName, true, false)
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
	nameWildcard = nameWildcard as String;
	if nameWildcard == "!":
		# Match the current selected set
		return get_tree().get_nodes_in_group(selectionGroup)

	var matches = []
	for a in actorsNode.get_children():
		if a.name.match(nameWildcard):
			matches.push_back(a)
	if matches.empty(): matches = get_tree().get_nodes_in_group(nameWildcard)
	if matches.empty():
		reportError("No matches found for: " + nameWildcard, sender)
	else:
		print("Matched: ", getNames(matches))
	return matches


# expectedArgs refers to the number of expected arguments
# *not* including the first (target) argument. It can be an
# integer or an array of two values (min/max number of allowed
# arguments).
func getActorsAndArgs(inArgs, methodName, expectedArgs, sender):
	if typeof(expectedArgs) == TYPE_INT: expectedArgs = [expectedArgs]
	if inArgs.size() > expectedArgs.front() and inArgs.size() <= expectedArgs.back() + 1:
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
func loadAsset(args, sender):
	if args.size() != 1:
		reportError("loadAsset expects one argument", sender)
		return
	var assetName = args[0]
	var assets = getAssetFilesMatching(animationAssetPath, assetName)
	if not assets.sprites.empty():
		loadSprites(assets.sprites)
		reportStatus("loaded sprites: " + String(assets.sprites), sender)
	if not assets.seqs.empty():
		loadSequences(assets.seqs)
		reportStatus("loaded sequences: " + String(assets.seqs), sender)
	

func createActor(args, sender):
	if args.size() != 2:
		reportError("createActor expects two arguments", sender)
		return
	var nodeName = args[0]
	var animName = args[1]
	if !animFramesLibrary.has_animation(animName):
		reportError("Anim not found: '%s'" % animName, sender)
		return
	var newNode
	if actorsNode.has_node(nodeName):
		print("replacing node '%s'" % [nodeName])
		newNode = actorsNode.get_node(nodeName)
	else:
		print("creating node '%s'" % [nodeName])
		newNode = metanode.instance()
		newNode.name = nodeName
		newNode.position = Vector2(randf(), randf()) * main.get_viewport_rect().size
		# Switch to the animation library that includes runtime-loaded data
		newNode.get_node("Animation").frames = animFramesLibrary
		actorsNode.add_child(newNode)

	var animNode = newNode.get_node("Animation")
	animNode.play(animName)
	# Set the offset of the child sprite so the MetaNode centre is near
	# its bottom (the "feet"). In future, this could be set differently
	# for each anim as metadata, but for now this is okay.
	var anim = animNode.get_animation()
	var texSize = animNode.frames.get_frame(animName, 0).get_size()
	animNode.position = Vector2(0, texSize.y * -0.45)
	reportStatus("Created node '%s' with '%s'" % [newNode.name, anim], sender)


# List the instantiated actors
func listActors(args, sender):
	if !args.empty():
		reportError("listActors expects no arguments", sender)
		return
	var pairs = {}
	for a in actorsNode.get_children():
		pairs[a.name] = a.get_node("Animation").get_animation()
	print(pairs)
	sendMessage(sender, "/list/actors/reply", pairs)


# List the loaded and available animations (or images)
func listAnims(args, sender):
	if !args.empty():
		reportError("listAnims expects no arguments", sender)
		return
	var names = []
	for a in animFramesLibrary.get_animation_names():
		names.push_back(a)
	print(names)
	sendMessage(sender, "/list/anims/reply", names)


# List the assets/files on disk
func listAssets(args, sender):
	if !args.empty():
		reportError("listAssets expects no arguments", sender)
		return
	var assets = getAssetFilesMatching(animationAssetPath, "*")
	var names = []
	for path in assets.sprites + assets.seqs:
		var name = getAssetBaseName(path.get_file())
		names.push_back(name)
	print(names)
	sendMessage(sender, "/list/assets/reply", names)


func groupActor(args, sender):
	var groupName = args[0]
	if args.size() == 1:
		# With no other arguments, just list the members
		var members = get_tree().get_nodes_in_group(groupName)
		reportStatus("'" + groupName + "' members: " + String(getNames(members)), sender)
	else:
		for node in matchNodes(args[1], sender):
			node.add_to_group(groupName)
	

func ungroupActor(args, sender):
	var groupName = args[0]
	for node in matchNodes(args[1], sender):
		if node.is_in_group(groupName):
			node.remove_from_group(groupName)
	

func selectActor(args, sender):
	if args.empty():
		listSelectedActors(args, sender)
	else:
		for node in matchNodes(args[0], sender):
			node.add_to_group(selectionGroup)
			setShaderUniform(node, "uSelected", true)


func deselectActor(args, sender):
	if args.empty(): args = ["*"];
	for node in matchNodes(args[0], sender):
		if node.is_in_group(selectionGroup):
			node.remove_from_group(selectionGroup)
		setShaderUniform(node, "uSelected", false)


func listSelectedActors(args, sender):
	if !args.empty():
		reportError("listSelectedActors expects no arguments", sender)
		return
	var nodes = get_tree().get_nodes_in_group(selectionGroup)
	reportStatus("selected: " + String(getNames(nodes)), sender)


func defCommand(args, sender):
	if args.size() < 2:
		reportError("defCommand expects at least two arguments", sender)
		return
	var defSplit = args[0].split(" ", false)
	var defName = defSplit[0]
	var defArgs = Array(defSplit).slice(1, -1) if defSplit.size() > 1 else []
	var defCmds = []
	for subCmd in args.slice(1, -1):
		defCmds.push_back(subCmd.split(" ", false))
	customCmds.defineCommand(defName, defArgs, defCmds)


func loadDefsFile(args, sender):
	if args.size() != 1:
		reportError("loadDefsFile expects one argument", sender)
		return
	var defsFile = "res://commands/" + args[0]
	if not customCmds.loadCommandFile(defsFile):
		reportError("Couldn't open defs file: '%s'" % [defsFile], sender)


func wait(args, sender):
	if args.size() != 1:
		reportError("wait expects one argument", sender)
		return
	var waitTime = args[0] as float
	return waitTime


############################################################
# OSC Actor commands
#   The first argument for all these commands is the target actor(s).
#   It may be "!" (selection), an actor instance name or a wildcard string.
############################################################
func freeActor(inArgs, sender):
	var args = getActorsAndArgs(inArgs, "freeActor", 0, sender)
	if args: for node in args.actors:
		actorsNode.remove_child(node)
	reportStatus("Freed: " + String([] if !args else getNames(args.actors)), sender)


func playActor(inArgs, sender):
	var args = getActorsAndArgs(inArgs, "playActor", 0, sender)
	if args: for node in args.actors:
		var animName = node.get_node("Animation").get_animation()
		node.get_node("Animation").play(animName)


func stopActor(inArgs, sender):
	var args = getActorsAndArgs(inArgs, "stopActor", 0, sender)
	if args: for node in args.actors:
		node.get_node("Animation").stop()


func setActorFrame(inArgs, sender):
	var args = getActorsAndArgs(inArgs, "setActorFrame", 1, sender)
	if args: for node in args.actors:
		node.get_node("Animation").set_frame(args.args[0])


func setActorPosition(inArgs, sender):
	var args = getActorsAndArgs(inArgs, "setActorPosition", [2, 3], sender)
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
				viewSize * Vector2(float(args.args[0]), float(args.args[1])),
				float(dur),
				Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			tween.start()


func setActorRotation(inArgs, sender):
	var args = getActorsAndArgs(inArgs, "setActorRotation", [1, 2], sender)
	if args:
		var dur = 0 if args.args.size() == 1 else args.args[1]
		for node in args.actors:
			var tween = node.get_node("Tween")
			tween.interpolate_property(node, "rotation_degrees",
				node.rotation_degrees,
				float(args.args[0]),
				float(dur),
				Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			tween.start()


func setActorScale(inArgs, sender):
	var args = getActorsAndArgs(inArgs, "setActorScale", [2, 3], sender)
	if args:
		var dur = 0 if args.args.size() == 2 else args.args[2]
		for node in args.actors:
			var tween = node.get_node("Tween")
			tween.interpolate_property(node, "scale",
				node.scale,
				Vector2(float(args.args[0]), float(args.args[1])),
				float(dur),
				Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			tween.start()


func setActorSpeed(inArgs, sender):
	var args = getActorsAndArgs(inArgs, "setActorSpeed", 1, sender)
	if args: for node in args.actors:
		node.get_node("Animation").set_speed_scale(args.args[0])


func flipActorH(inArgs, sender):
	var args = getActorsAndArgs(inArgs, "flipActorH", 0, sender)
	if args: for node in args.actors:
		var anim = node.get_node("Animation")
		anim.set_flip_h(not(anim.is_flipped_h()))


func flipActorV(inArgs, sender):
	var args = getActorsAndArgs(inArgs, "flipActorV", 0, sender)
	if args: for node in args.actors:
		var anim = node.get_node("Animation")
		anim.set_flip_v(not(anim.is_flipped_v()))


func colorActor(inArgs, sender):
	var args = getActorsAndArgs(inArgs, "colorActor", 3, sender)
	if args:
		var rgb = Vector3(args.args[0], args.args[1], args.args[2])
		for node in args.actors:
			setShaderUniform(node, "uAddColor", rgb)


func sayActor(inArgs, sender):
	var aa = getActorsAndArgs(inArgs, "sayActor", [1, 2], sender)
	if aa:
		for node in aa.actors:
			var msg = String(aa.args[0])
			var bubble = speechBubbleNode.instance()
			node.add_child(bubble)
			if len(aa.args) == 2:
				bubble.setText(msg, aa.args[1])
			else:
				bubble.setText(msg)
