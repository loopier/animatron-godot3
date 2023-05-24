extends Node

# By default, perform status reporting when running in Godot editor,
# but not on exported builds. Can be overridden at runtime with /debug message.
var allowStatusReport : bool = not OS.has_feature("standalone")
onready var main = get_parent()
onready var post = main.get_node("PostTextEdit")
onready var actorsNode = main.get_node("Actors")
onready var customCmds : CustomCommands = main.get_node("CustomCommands")
onready var config : Config = main.get_node("Config")
onready var metanode = preload("res://MetaNode.tscn")
onready var routineNode = preload("res://RoutineNode.tscn")
onready var routinesNode = main.get_node("Routines")
onready var speechBubbleNode = preload("res://SpeechBubble.tscn")
onready var audioInputNode = main.get_node("AudioInputPlayer")
onready var midiNode = main.get_node("Midi")
onready var oscNode = main.get_node("OscSender")
var animFramesLibrary
var spriteFilenameRegex
var sequenceFilenameRegex
const selectionGroup := "selected"
const loadAllAssetsAtStartup := false
const actorAnimNodePath := "Offset/Animation"
const defaultDefsDir := "commands/"
const defaultBgColor := Color(0.1, 0.1, 0.1)

func _ready():
	spriteFilenameRegex = RegEx.new()
	spriteFilenameRegex.compile("(.+?)(?:_(\\d+)dir)?_(\\d+)x(\\d+)_(\\d+)fps")
	sequenceFilenameRegex = RegEx.new()
	sequenceFilenameRegex.compile("(.+)_(\\d+)fps")

	animFramesLibrary = metanode.instance().get_node(actorAnimNodePath).frames
	if loadAllAssetsAtStartup:
		var assets = getAssetFilesMatching(config.animationAssetPath, "*")
		loadSprites(assets.sprites)
		loadSequences(assets.seqs)
	
	setBackgroundColor([defaultBgColor.r, defaultBgColor.g, defaultBgColor.b], null)

############################################################
# Helpers
############################################################
static func getAssetBaseName(fileName):
	var baseName = fileName.get_basename()
	var split = baseName.split("_", false, 1)
	if !split.empty(): baseName = split[0]
	return baseName


static func getAnimSequenceFrames(path):
	var dir = Directory.new()
	var frames = []
	if dir.open(path) == OK:
		dir.list_dir_begin(true, true)
		var filename = dir.get_next()
		while !filename.empty() and !dir.current_is_dir():
			if filename.ends_with(".png") or filename.ends_with(".jpg"):
				frames.push_back(filename)
			filename = dir.get_next()
	frames.sort()
	return frames


static func getAssetFilesMatching(path, nameWildcard):
	var dir = Directory.new()
	var files = { sprites = [], seqs = [] }
	if dir.open(path) == OK:
		dir.list_dir_begin(true, true)
		var filename = dir.get_next()
		while !filename.empty():
			var fullPath = path.plus_file(filename)
			if dir.current_is_dir():
				var baseFile = getAssetBaseName(filename)
				if baseFile.match(nameWildcard):
					var seqFrames = getAnimSequenceFrames(fullPath);
					if !seqFrames.empty():
						Logger.debug("Sequence (%d frames) file name: %s" % [seqFrames.size(), filename])
						files.seqs.push_back(fullPath)
			elif filename.ends_with(".png") or filename.ends_with(".jpg"):
				var baseFile = getAssetBaseName(filename)
				if baseFile.match(nameWildcard):
					Logger.verbose("File name: %s" % [filename])
					files.sprites.push_back(fullPath)
			filename = dir.get_next()
	return files


static func getExternalTexture(path):
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
		dict.directions = 1 if result.get_string(2).empty() else result.get_string(2).to_int()
		dict.xStep = result.get_string(3).to_int()
		dict.yStep = result.get_string(4).to_int()
		dict.fps = result.get_string(5).to_int()
		Logger.debug(dict)
	else:
		dict.name = name
		dict.directions = 1
		dict.xStep = 1
		dict.yStep = 1
		dict.fps = 0
	return dict


func getSeqFileInfo(name):
	var dict = {}
	var result = sequenceFilenameRegex.search(name)
	if result:
		dict.name = result.get_string(1)
		dict.fps = result.get_string(2).to_int()
		Logger.debug(dict)
	else:
		dict.name = name
		dict.fps = 24
	return dict


# Add directions or actions from a spritesheet that may contain several
# NOTE: Currently assumes there are equal numbers of sprites per sub-action,
#       and does not support offsets or anything more flexible.
func addSubSprites(animFramesLibrary, atlas, suffixes, info):
	var totalFrames : int = info.xStep * info.yStep
	var subFrames : int = totalFrames / info.directions
	assert(suffixes.size() == info.directions)
	var width = atlas.get_size().x / info.xStep
	var height = atlas.get_size().y / info.yStep
	for suffix in suffixes:
		var animName = info.name + suffix
		animFramesLibrary.remove_animation(animName)
		animFramesLibrary.add_animation(animName)
		animFramesLibrary.set_animation_speed(animName, info.fps)
	var frameId = 0
	for y in range(0, info.yStep):
		for x in range(0, info.xStep):
			var texture : AtlasTexture = AtlasTexture.new()
			texture.atlas = atlas
			texture.region = Rect2(width * x, height * y, width, height)
			texture.margin = Rect2(0, 0, 0, 0)
			var subAnim = frameId / subFrames
			var animName = info.name + suffixes[subAnim]
			animFramesLibrary.add_frame(animName, texture, frameId % subFrames)
			frameId += 1


func loadSprites(sprites):
	Logger.debug("Runtime sprites: %s" % [sprites])
	# Add the runtime-loaded sprites to our pre-existing library
	for spritePath in sprites:
		var res
		# res = load(spritePath)
		if !res: res = getExternalTexture(spritePath)
		if res:
			var info = getSpriteFileInfo(spritePath.get_file().get_basename())
			if info.directions == 8:
				var dirSuffixes = ["-s", "-se", "-e", "-ne", "-n", "-nw", "-w", "-sw"]
				addSubSprites(animFramesLibrary, res, dirSuffixes, info)
			else:
				addSubSprites(animFramesLibrary, res, [""], info)


func loadSequences(sequences):
	Logger.debug("Runtime sequences: %s" % [sequences])
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
static func sendMessage(target, oscAddress, oscArgs):
	if not target:
		return
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
	Logger.error(errString)
	if target:
		sendMessage(target, "/error/reply", [errString])


func reportStatus(statusString, target):
	if not allowStatusReport:
		return
	Logger.info(statusString)
	if target:
		sendMessage(target, "/status/reply", [statusString])


func getNode(nodeName, sender):
	var node = actorsNode.find_node(nodeName, true, false)
	if node:
		return node
	else:
		reportError("Node not found: " + nodeName, sender)
		return false


static func getNames(objList):
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
		reportStatus("No matches found for: " + nameWildcard, sender)
	elif allowStatusReport:
		Logger.verbose("Matched: %s" % [getNames(matches)])
	return matches


# expectedArgs refers to the number of expected arguments
# *not* including the first (target) argument. It can be an
# integer or an array of two values (min/max number of allowed
# arguments). If it's null then it allows any number of args.
func getActorsAndArgs(inArgs, methodName, expectedArgs, sender):
	if typeof(expectedArgs) == TYPE_INT: expectedArgs = [expectedArgs]
	elif typeof(expectedArgs) == TYPE_NIL: expectedArgs = [0, 1000]
	if inArgs.size() > expectedArgs.front() and inArgs.size() <= expectedArgs.back() + 1:
		return { actors = matchNodes(inArgs[0], sender), args = inArgs.slice(1, -1) }
	else:
		reportError(methodName + ": unexpected number of arguments: " + String(inArgs.size()) + " instead of target plus " + String(expectedArgs), sender)
		return


static func setPropertyWithDur(node, propertyName : String, newValue, dur : float, tweenPath := "Tween"):
	if dur > 0:
		var tween = node.get_node(tweenPath)
		tween.interpolate_property(node, propertyName,
			node.get(propertyName),
			newValue,
			float(dur),
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
	else:
		node.set(propertyName, newValue)


static func setShaderUniform(node, uName, uValue):
	var image = node.get_node(actorAnimNodePath)
	image.material.set_shader_param(uName, uValue)

static func getShaderUniform(node, uName):
	var image = node.get_node(actorAnimNodePath)
	return image.material.get_shader_param(uName)

static func removeActions(actor : Node):
	var toRemove := []
	for child in actor.get_children():
		if child as Action:
			actor.remove_child(child)
			var offset : Node2D = actor.get_node("Offset")
			offset.position = Vector2(0, 0)
			offset.rotation_degrees = 0
			offset.scale = Vector2(1, 1)


# The pivot should be specified in relative coordinates,
# from 0 (left/top) to 1 (right/bottom). (0.5,0.5) is the centre (also default).
func setAnimPivot(animNode, pivot := Vector2(0.5, 0.5), dur : float = 0):
	var animName = animNode.animation
	var texSize = animNode.frames.get_frame(animName, 0).get_size()
	var pixelPivot = Vector2(0.5 - pivot.x, 0.5 - pivot.y) * texSize
	setPropertyWithDur(animNode, "position", pixelPivot, dur, "../../Tween")


############################################################
# OSC "other" commands
############################################################
func loadAsset(args, sender):
	if args.size() != 1:
		reportError("loadAsset expects one argument", sender)
		return
	var assetName : String = args[0]
	var assets = getAssetFilesMatching(config.animationAssetPath, assetName)
	if not assets.sprites.empty():
		loadSprites(assets.sprites)
		reportStatus("loaded sprites: " + String(assets.sprites), sender)
	if not assets.seqs.empty():
		loadSequences(assets.seqs)
		reportStatus("loaded sequences: " + String(assets.seqs), sender)


func createActor(args, sender=null):
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
		if allowStatusReport:
			Logger.info("replacing node '%s'" % [nodeName])
		newNode = actorsNode.get_node(nodeName)
	else:
		if allowStatusReport:
			Logger.info("creating node '%s'" % [nodeName])
		newNode = metanode.instance()
		newNode.name = nodeName
		newNode.position = Vector2(0.5, 0.5) * main.get_viewport_rect().size
		# Switch to the animation library that includes runtime-loaded data
		newNode.get_node(actorAnimNodePath).frames = animFramesLibrary
		actorsNode.add_child(newNode)

	var animNode = newNode.get_node(actorAnimNodePath)
	animNode.play(animName)
	# Set the offset/pivot of the child sprite to the default.
	setAnimPivot(animNode)
	reportStatus("Created node '%s' with '%s'" % [newNode.name, animName], sender)

func createActorGroup(args, sender=null):
	# args: groupName, animName, numOfInstances
	if args.size() != 3:
		reportError("createActorGroup expects two arguments", sender)
		return
	for i in range(args[2]):
		var actorName = "%s%d" % [args[0], i]
		var animName = args[1]
		createActor([actorName, animName], sender)
		groupActor([args[0], actorName], sender)
	groupActor([args[0]], sender)


func createOrDestroyActor(args, sender):
	if args.size() != 2:
		reportError("createOrDestroyActor expects two arguments", sender)
		return
	var nodeName = args[0]
	if actorsNode.has_node(nodeName):
		freeActor(args.slice(0,0), sender)
	else:
		createActor(args, sender)


func ySortActors(args, sender):
	if (args.size() > 1):
		reportError("ySortActors expects 0 or 1 bool argument", sender)
		return
	var sort := Helper.getBool(args[0]) if args.size() == 1 else true
	actorsNode.sort_enabled = sort
	reportStatus("y-sorting: %s" % ["enabled" if sort else "disabled"], sender)


# List the instantiated actors
func listActors(args, sender):
	if !args.empty():
		reportError("listActors expects no arguments", sender)
		return
	var pairs = {}
	var actors = actorsNode.get_children()
	actors.sort()
	Logger.info("List of Actors:")
	for a in actors:
		var anim = a.get_node(actorAnimNodePath).get_animation()
		pairs[a.name] = anim
		Logger.info("%s - %s" % [a.name, anim])
	sendMessage(sender, "/list/actors/reply", pairs)


# List the loaded and available animations (or images)
func listAnims(args, sender):
	if !args.empty():
		reportError("listAnims expects no arguments", sender)
		return
	var names = []
	Logger.info("List of loaded Animations:")
	for a in animFramesLibrary.get_animation_names():
		names.push_back(a)
		Logger.info(a)
	sendMessage(sender, "/list/anims/reply", names)


# List the assets/files on disk
func listAssets(args, sender):
	if !args.empty():
		reportError("listAssets expects no arguments", sender)
		return
	var assets = getAssetFilesMatching(config.animationAssetPath, "*")
	var names = []
	var paths = assets.sprites + assets.seqs
	paths.sort()
	Logger.info("List of available Animations:")
	for i in range(len(paths)):
		var path = paths[i]
		var numImgs = len(getAnimSequenceFrames(path))
		var name = getAssetBaseName(path.get_file())
		names.push_back(name)
		Logger.info("%s (%d)" % [name, numImgs])
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

# send a command to every member of the group
func iterateGroup(args, sender):
	var cmdAddr = args[0]
	var groupName = args[1]
	var cmdArgs = Array(args).slice(2, -1) if args.size() > 1 else []
	var members = get_tree().get_nodes_in_group(groupName)
	Logger.verbose("iterate: %s" % [groupName])
	var cmds : Array
	for member in members:
		var cmd = [cmdAddr, member.name]
		cmd.append_array(cmdArgs)
		cmds.append(cmd)
		Logger.verbose("cmd: %s" % [cmd])
	main.evalCommandList(cmds, sender)

# Send a command to a specific member in the group by index.
# This allows for /defs to send commands to specific (indexed) members of a group
# in a generic way (passing the group as argument).
# Example: /at 3 /frame gp 0 --> /frame gp3 0
func atGroupItem(args, sender):
	var cmd = [args[1]]
	var groupName = args[2]
	var cmdArgs = Array(args).slice(3, -1) if args.size() > 2 else []
	var members = get_tree().get_nodes_in_group(groupName)
	var index = int(args[0]) % len(members)
	var member = members[index]
	cmd.append(member.name)
	cmd.append_array(cmdArgs)
	Logger.verbose("cmd at: %s" % [cmd])
	main.evalCommandList([cmd], sender)

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
	var defsFile = Helper.getPathWithDefaultDir(args[0], defaultDefsDir)
	if customCmds.loadCommandFile(defsFile):
		reportStatus("Loaded custom defs from '%s'" % defsFile, sender)
	else:
		reportError("Couldn't open defs file: '%s'" % [defsFile], sender)


func enableStatusMessages(args, sender):
	if (args.size() > 1):
		reportError("enableStatusMessages expects 0 or 1 bool argument", sender)
		return
	allowStatusReport = Helper.getBool(args[0]) if args.size() == 1 else true
	reportStatus("Status messages: %s" % ["enabled" if allowStatusReport else "disabled"], sender)

func midiEnableStatusMessages(args, sender):
	if (args.size() != 1):
		reportError("midiEnableStatusMessages 1 bool argument", sender)
		return
	midiNode.enableDebug(args[0])

func wait(args, sender):
	if args.size() != 1:
		reportError("wait expects one argument", sender)
		return
	var waitTime = args[0] as float
	return waitTime

############################################################
# App commands
############################################################
func setBackgroundColor(args, sender):
	if len(args) != 3:
		reportError("listCommands expects 3 arguments", sender)
		return
	var r = float(args[0])
	var g = float(args[1])
	var b = float(args[2])
	VisualServer.set_default_clear_color(Color(r,g,b))

func listCommands(args, sender):
	if !args.empty():
		reportError("listCommands expects no arguments", sender)
		return
	var commandsMsg = "\n=== ACTOR ===\n" + main.getActorCommandSummary()
	commandsMsg += "\n\n=== OTHER ===\n" + main.getOtherCommandSummary()
	commandsMsg += "\n\n=== CUSTOM ===\n" + customCmds.getCommandSummary()
	reportStatus("/list/commands/reply %s" % commandsMsg, sender)
	
	Logger.info(commandsMsg)

func openHelp(args, sender):
	if !args.empty():
		reportError("openHelp expects no arguments", sender)
	OS.shell_open(ProjectSettings.globalize_path("res://docs/Reference.md.html"))

func postUserDataPath(args, sender):
	reportStatus(OS.get_user_data_dir(), sender)

func openFile(args, sender):
	if len(args) != 0:
		main.openFile(args[0])
		return
	main.get_node("OpenFileDialog").popup()

func saveFile(args, sender):
	if len(args) != 0:
		main.saveFile(args[0])
		return
	main.get_node("SaveFileDialog").popup()

func loadTutorial(args, sender):
	main.get_node("OscTextEdit").loadTutorial()

func editorAppend(args, sender):
	main.get_node("OscTextEdit").append(" ".join(args))

func editorFontSize(args, sender):
	if len(args) < 1:
		reportError("editorFontSize expects 1 argument.", sender)
		return
	main.get_node("OscTextEdit").setFontSize(float(args[0]))

func editorIncreaseFont(args, sender):
	if len(args) > 0:
		reportError("editorIncreaseFont expects 0 argument.", sender)
		return
	main.get_node("OscTextEdit").increaseFont()

func editorDecreaseFont(args, sender):
	if len(args) > 0:
		reportError("editorDecreaseFont expects 0 argument.", sender)
		return
	main.get_node("OscTextEdit").decreaseFont()

func editorClear(args, sender):
	main.get_node("OscTextEdit").clear()

func postMsg(args, sender):
	main.post(" ".join(args))
	
func postFontSize(args, sender):
	if len(args) < 1:
		reportError("postFontSize expects 1 argument.", sender)
		return
	main.get_node("PostTextEdit").setFontSize(float(args[0]))

func postIncreaseFont(args, sender):
	if len(args) > 0:
		reportError("postIncreaseFont expects 0 argument.", sender)
		return
	main.get_node("PostTextEdit").increaseFont()

func postDecreaseFont(args, sender):
	if len(args) > 0:
		reportError("postDecreaseFont expects 0 argument.", sender)
		return
	main.get_node("PostTextEdit").decreaseFont()

############################################################
# Logger commands
############################################################
func setLogLevel(args, sender):
	if len(args) < 1:
		reportError("setLogLevel expects 1 argument.", sender)
		return
	var level = Logger.levelNames.find(args[0].to_upper())
	Logger.setLevel(level)

func logMsg(args, sender):
	Logger.logMsg(" ".join(args))

############################################################
# OSC sending commands
############################################################

func connectOscRemote(args, sender):
	oscNode.connectRemote(args)

func sendOsc(args, sender):
	oscNode.send(args)

############################################################
# OSC Actor commands
#   The first argument for all these commands is the target actor(s).
#   It may be "!" (selection), an actor instance name or a wildcard string.
############################################################
func freeActor(inArgs, sender):
#	soundFreeActor(inArgs, sender)
#	midiFreeActor(inArgs, sender)
	
	var args = getActorsAndArgs(inArgs, "freeActor", 0, sender)
	if args: for node in args.actors:
		actorsNode.remove_child(node)
	reportStatus("Freed: " + String([] if !args else getNames(args.actors)), sender)

func setActorAnim(inArgs, sender):
	var args = getActorsAndArgs(inArgs, "setActorAnim", 1, sender)
	if args: for node in args.actors:
		var animNode = node.get_node(actorAnimNodePath)
		var animName = args.args[0]
		if !animFramesLibrary.has_animation(animName):
			reportError("Anim not found: '%s'" % animName, sender)
			return
		# Switch to the animation library that includes runtime-loaded data
#		node.get_node(actorAnimNodePath).frames = animFramesLibrary
		animNode.play(animName)
		reportStatus("Changed node '%s' animation to '%s'" % [node.name, animName], sender)
		
func playActor(inArgs, sender):
	var args = getActorsAndArgs(inArgs, "playActor", null, sender)
	if args: for node in args.actors:
		var animNode = node.get_node(actorAnimNodePath)
		var animName = animNode.get_animation()
		animNode.play(animName)

func playActorReverse(inArgs, sender):
	var args = getActorsAndArgs(inArgs, "playActor", null, sender)
	if args: for node in args.actors:
		var animNode = node.get_node(actorAnimNodePath)
		var animName = animNode.get_animation()
		var reverse = true
		if len(args.args) > 0:
			reverse = args.args[0]
		animNode.play(animName, reverse)
	

func playActorRandom(inArgs, sender):
	var args = getActorsAndArgs(inArgs, "playActor", [0,1], sender)
	var rand := Helper.getBool(args.args[0]) if not args.args.empty() else true
	if args: for node in args.actors:
		var animNode = node.get_node(actorAnimNodePath)
#		var animName = animNode.get_animation_list()
#		var randomAnimation = animName[randi() % animName.size()]
#		animNode.play(randomAnimation)
		animNode.random = rand

func stopActor(inArgs, sender):
	var args = getActorsAndArgs(inArgs, "stopActor", 0, sender)
	if args: for node in args.actors:
		node.get_node(actorAnimNodePath).stop()


func setActorFrame(inArgs, sender):
	var args = getActorsAndArgs(inArgs, "setActorFrame", 1, sender)
	if args: for node in args.actors:
		var anim = node.get_node(actorAnimNodePath)
		var frame = int(args.args[0])
		if typeof(frame) != TYPE_INT:
			frame = int(frame * anim.frames.get_frame_count(anim.animation))
			Logger.debug("%s's frame: %s" % [frame])
		anim.set_frame(fposmod(frame, anim.frames.get_frame_count(anim.animation)))


func setActorPosition(inArgs, sender):
	var args = getActorsAndArgs(inArgs, "setActorPosition", [2, 3], sender)
	if args:
		var viewSize = Vector2(
			ProjectSettings.get_setting("display/window/size/width"),
			ProjectSettings.get_setting("display/window/size/height")
		)
		var dur : float = 0 if args.args.size() == 2 else args.args[2]
		for node in args.actors:
			var newPos : Vector2 = viewSize * Vector2(float(args.args[0]), float(args.args[1]))
			setPropertyWithDur(node, "position", newPos, dur)

func setActorPositionX(inArgs, sender):
	var args = getActorsAndArgs(inArgs, "setActorPosition", [1, 2], sender)
	if args:
		var viewSize = Vector2(
			ProjectSettings.get_setting("display/window/size/width"),
			ProjectSettings.get_setting("display/window/size/height")
		)
		var dur : float = 0 if args.args.size() == 1 else args.args[1]
		for node in args.actors:
			var x = viewSize.x * float(args.args[0])
			var y = node.get("position").y
			setPropertyWithDur(node, "position", Vector2(x, y), dur)

func setActorPositionY(inArgs, sender):
	var args = getActorsAndArgs(inArgs, "setActorPosition", [1, 2], sender)
	if args:
		var viewSize = Vector2(
			ProjectSettings.get_setting("display/window/size/width"),
			ProjectSettings.get_setting("display/window/size/height")
		)
		var dur : float = 0 if args.args.size() == 1 else args.args[1]
		for node in args.actors:
			var x = node.get("position").x
			var y = viewSize.y * float(args.args[0])
			setPropertyWithDur(node, "position", Vector2(x, y), dur)

func moveActor(inArgs, sender):
	var args = getActorsAndArgs(inArgs, "moveActor", [2,3], sender)
	if args:
		var dur : float = 0 if args.args.size() == 2 else args.args[1]
		for node in args.actors:
			var x = (node.get("position").x / Helper.getViewSize().x) + float(args.args[0])
			var y = (node.get("position").y / Helper.getViewSize().y) + float(args.args[1])
			Logger.debug("node:%s x:%0.2f y:%0.2f" % [node.name, x, y])
			setActorPosition([node.name, x, y, dur], sender)

func moveActorX(inArgs, sender):
	var args = getActorsAndArgs(inArgs, "moveActor", [1,2], sender)
	if args:
		var dur : float = 0 if args.args.size() == 1 else args.args[1]
		for node in args.actors:
			var x = (node.get("position").x / Helper.getViewSize().x) + float(args.args[0])
			setActorPositionX([node.name, x, dur], sender)
			
func moveActorY(inArgs, sender):
	var args = getActorsAndArgs(inArgs, "moveActor", [1,2], sender)
	if args:
		var dur : float = 0 if args.args.size() == 1 else args.args[1]
		for node in args.actors:
			var y = (node.get("position").y / Helper.getViewSize().y) + float(args.args[0])
			setActorPositionY([node.name, y, dur], sender)

func setActorAngle(inArgs, sender):
	var args = getActorsAndArgs(inArgs, "setActorRotation", [1, 2], sender)
	if args:
		var dur : float = 0 if args.args.size() == 1 else args.args[1]
		var angle := float(args.args[0])
		for node in args.actors:
			setPropertyWithDur(node, "rotation_degrees", angle, dur)

func rotateActor(inArgs, sender):
	var args = getActorsAndArgs(inArgs, "setActorRotation", [1, 2], sender)
	if args:
		var dur : float = 0 if args.args.size() == 1 else args.args[1]
		for node in args.actors:
			var angle : float = node.get("rotation_degrees") + float(args.args[0])
			Logger.debug("angle: get:%.2f + add:%.2f = %.2f" % [node.get("rotation_degrees"), float(args.args[0]), angle])
			setActorAngle([node.name, angle, dur], sender)


func setActorScale(inArgs, sender):
	var aa = getActorsAndArgs(inArgs, "setActorScale", [1, 2], sender)
	if aa:
		var dur : float = 0 if aa.args.size() == 1 else aa.args[1]
		var scl := Helper.getVector2(aa.args[0])
		for node in aa.actors:
			setPropertyWithDur(node, "scale", scl, dur)

func setActorScaleXY(inArgs, sender):
	var aa = getActorsAndArgs(inArgs, "setActorScaleXY", [2, 3], sender)
	if aa:
		var dur : float = 0 if aa.args.size() == 2 else aa.args[2]
		var scl := Helper.getVector2(aa.args.slice(0,2))
		for node in aa.actors:
			setPropertyWithDur(node, "scale", scl, dur)

func setActorScaleX(inArgs, sender):
	var aa = getActorsAndArgs(inArgs, "setActorScaleX", [1, 2], sender)
	if aa:
		var dur : float = 0 if aa.args.size() == 1 else aa.args[1]
		for node in aa.actors:
			var scl := Vector2(aa.args[0], node.get("scale").y)
			Logger.verbose("scale: %.2f" % [node.get("scale").y])
			setPropertyWithDur(node, "scale", scl, dur)

func setActorScaleY(inArgs, sender):
	var aa = getActorsAndArgs(inArgs, "setActorScaleX", [1, 2], sender)
	if aa:
		var dur : float = 0 if aa.args.size() == 1 else aa.args[1]
		for node in aa.actors:
			var scl := Vector2(node.get("scale").x, aa.args[0])
			Logger.verbose("scale: %.2f" % [node.get("scale").y])
			setPropertyWithDur(node, "scale", scl, dur)

func setActorPivot(inArgs, sender):
	var aa = getActorsAndArgs(inArgs, "setActorPivot", [2, 3], sender)
	if aa:
		var dur : float = 0 if aa.args.size() == 2 else aa.args[2]
		var pivot := Vector2(float(aa.args[0]), float(aa.args[1]))
		for node in aa.actors:
			var animNode = node.get_node(actorAnimNodePath)
			setAnimPivot(animNode, pivot, dur)

func setActorFade(inArgs, sender):
	var args = getActorsAndArgs(inArgs, "setActorFade", [1, 2], sender)
	if args:
		var dur : float = 0 if args.args.size() == 1 else args.args[1]
		var target := Color(1, 1, 1, float(args.args[0]))
		for node in args.actors:
			setPropertyWithDur(node, "modulate", target, dur)


func setActorSpeed(inArgs, sender):
	var args = getActorsAndArgs(inArgs, "setActorSpeed", 1, sender)
	var speed := args.args[0] as float
	if args: for node in args.actors:
		var animNode = node.get_node(actorAnimNodePath)
		if speed < 0:
			animNode.play("", true)
		else:
			animNode.play("")
		animNode.set_speed_scale(abs(speed))

func flipActorH(inArgs, sender):
	var args = getActorsAndArgs(inArgs, "flipActorH", 0, sender)
	if args: for node in args.actors:
		var anim = node.get_node(actorAnimNodePath)
		anim.set_flip_h(not(anim.is_flipped_h()))


func flipActorV(inArgs, sender):
	var args = getActorsAndArgs(inArgs, "flipActorV", 0, sender)
	if args: for node in args.actors:
		var anim = node.get_node(actorAnimNodePath)
		anim.set_flip_v(not(anim.is_flipped_v()))


func colorActor(inArgs, sender):
	var args = getActorsAndArgs(inArgs, "colorActor", 3, sender)
	if args:
		var rgb = Vector3(args.args[0], args.args[1], args.args[2])
		for node in args.actors:
			setShaderUniform(node, "uAddColor", rgb)

func colorRedActor(inArgs, sender):
	var args = getActorsAndArgs(inArgs, "colorActor", 1, sender)
	if args:
		for actor in args.actors:
			var rgb = getShaderUniform(actor, "uAddColor")
			rgb.x = float(args.args[0])
			setShaderUniform(actor, "uAddColor", rgb)
			
func colorGreenActor(inArgs, sender):
	var args = getActorsAndArgs(inArgs, "colorActor", 1, sender)
	if args:
		for actor in args.actors:
			var rgb = getShaderUniform(actor, "uAddColor")
			rgb.y = float(args.args[0])
			setShaderUniform(actor, "uAddColor", rgb)

func colorBlueActor(inArgs, sender):
	var args = getActorsAndArgs(inArgs, "colorActor", 1, sender)
	if args:
		for actor in args.actors:
			var rgb = getShaderUniform(actor, "uAddColor")
			rgb.z = float(args.args[0])
			setShaderUniform(actor, "uAddColor", rgb)
			
func sayActor(inArgs, sender):
	var aa = getActorsAndArgs(inArgs, "sayActor", [1, 2], sender)
	if aa:
		for node in aa.actors:
			var msg = String(aa.args[0])
			var bubble = speechBubbleNode.instance()
			node.add_child(bubble)
			if len(aa.args) == 2:
				bubble.setText(msg, float(aa.args[1]))
			else:
				bubble.setText(msg)


func actionActor(inArgs, sender):
	var aa = getActorsAndArgs(inArgs, "actionActor", null, sender)
	if aa:
		for actor in aa.actors:
			removeActions(actor)
			if not aa.args.empty():
				var actionName = String(aa.args[0])
				var actionArgs = aa.args.slice(1, -1)
				var resource = load("res://actions/%s.gd" % actionName)
				if resource:
					var action = load("res://actions/%s.gd" % actionName).new(actionArgs)
					if action:
						actor.add_child(action)
						action.name = actionName
						reportStatus("added action '%s' to '%s' with args %s" % [actionName, actor.name, actionArgs], sender)
				else:
					reportError("Action '%s' not found" % actionName, sender)


func behindActor(inArgs, sender):
	var aa = getActorsAndArgs(inArgs, "behindActor", 1, sender)
	if aa:
		var references = matchNodes(aa.args[0], sender)
		var minIndex = actorsNode.get_child_count()
		for ref in references:
			minIndex = min(ref.get_index(), minIndex)
		# Here we want to reverse iterate, to keep the ordering
		for index in range(aa.actors.size()-1, -1, -1):
			var node = aa.actors[index]
			if node.get_index() > minIndex:
				var reference = String(aa.args[0])
				Logger.verbose("Move %s behind %s" % [node.name, reference])
				actorsNode.move_child(node, minIndex)


func frontActor(inArgs, sender):
	var aa = getActorsAndArgs(inArgs, "frontActor", 1, sender)
	if aa:
		var references = matchNodes(aa.args[0], sender)
		var maxIndex = 0
		for ref in references:
			maxIndex = max(ref.get_index(), maxIndex)
		for node in aa.actors:
			if node.get_index() < maxIndex:
				var reference = String(aa.args[0])
				Logger.verbose("Move %s in front of %s" % [node.name, reference])
				actorsNode.move_child(node, maxIndex)

func soundActor(inArgs, sender):
	var aa = false
	var rangemin = 0.0
	var rangemax = 1.0
	if len(inArgs) == 3:
		aa = getActorsAndArgs(inArgs.slice(2, -1), "soundActor", 0, sender)
	else:
		aa = getActorsAndArgs(inArgs.slice(2, -1), "soundActor", 2, sender)
		rangemin = aa.args[0]
		rangemax = aa.args[1]
	var band = inArgs[0]
	var cmd = inArgs[1]
	
	if aa:
		for actor in aa.actors:
			audioInputNode.addSoundCmd(band, cmd, actor, rangemin, rangemax)

func soundFreeActor(inArgs, sender):
	if len(inArgs) != 1 and len(inArgs) != 3:
		reportError("SoundFreeActor: unexpected number of arguments: " + String(inArgs.size()) + " instead of 1 or 3", sender)
		return
	
	var band = inArgs[0]
	var aa = getActorsAndArgs(inArgs.slice(2,-1), "soundFreeActor", 0, sender)
	if aa:
		for actor in aa.actors:
			var cmd = inArgs[1]
			audioInputNode.removeSoundCmd(band, cmd, actor)
	else:
		audioInputNode.removeAllSoundCmds(band)

# see MetaNode.gd for information on differences between MIDI messages
func midiActor(inArgs, sender):
	if len(inArgs) < 4:
		reportError("midiActor expects at least 4 arguments", sender)
		return
	var signalmap = {
		"noteon": "note_on_received",
		"noteoff": "note_off_received",
		"cc": "cc_received",
		"velocity": "note_on_received",
	}
	var midimsg = inArgs[0]
	var ch = int(inArgs[1])
	var num = inArgs[2]
	var cmd = inArgs[3]
	var signalmsg = signalmap[midimsg]
	var numArgs = len(inArgs.slice(4,-1)) - 1
	var aa  = getActorsAndArgs(inArgs.slice(4,-1), "midiActor", numArgs, sender)
#	print("MIDI msg:%s - singal:%s - num:%s - cmd:%s" % [midimsg, signalmsg, num, cmd])
	
	if aa:
		for actor in aa.actors:
			var rangemin = null
			var rangemax = null
			if len(aa.args) > 0: 
				rangemin = int(aa.args[0])
				rangemax = int(aa.args[1])
				Logger.debug("MIDI msg:%s - singal:%s - ch:%d - num:%s - cmd:%s min:%.2f max%.2f" % [midimsg, signalmsg, ch, num, cmd, rangemin, rangemax])
			else:
				# print null
				Logger.debug("MIDI msg:%s - singal:%s - ch:%d - num:%s - cmd:%s min:- max-" % [midimsg, signalmsg, ch, num, cmd])
			midiNode.addMidiCmd(midimsg, ch, num, cmd, actor, rangemin, rangemax)

func midiFreeActor(inArgs, sender):
	if len(inArgs) != 5:
		reportError("midiActor expects 6 arguments", sender)
		return
	var signalmap = {
		"noteon": "note_on_received",
		"noteoff": "note_off_received",
		"cc": "cc_received",
		"velocity": "note_on_received",
	}
	var midimsg = inArgs[0]
	var ch = inArgs[1]
	var num = inArgs[2]
	var cmd = inArgs[3]
	var signalmsg = signalmap[midimsg]
	var aa = getActorsAndArgs(inArgs.slice(4,-1), "midiActor", 0, sender)
#	print("MIDI msg:%s - singal:%s - num:%s - cmd:%s" % [midimsg, signalmsg, num, cmd])
	
	if aa:
		for actor in aa.actors:
			Logger.debug("_on_Midi_%s" % signalmsg)
#			midiNode.disconnect(signalmsg, actor, "_on_Midi_%s" % signalmsg)
			midiNode.removeMidiCmd(midimsg, ch, num, cmd, actor)
			return
			
			if midimsg == "noteon" and typeof(num) == TYPE_INT:
				midiNode.removeMidiNoteOnCmd(ch, num, cmd, actor)
			elif midimsg == "noteon" and num == "*":
				midiNode.removeMidiAnyNoteOnCmd(ch, cmd, actor)
			elif midimsg == "noteoff" and typeof(num) == TYPE_INT:
				midiNode.removeMidiNoteOffCmd(ch, num, cmd, actor)
			elif midimsg == "noteoff" and num == "*":
				midiNode.removeMidiAnyNoteOffCmd(ch, cmd, actor)
			elif midimsg == "cc":
				midiNode.removeMidiCcCmd(ch, num, cmd, actor)
			elif midimsg == "velocity":
				midiNode.removeMidiVelocityCmd(ch, cmd, actor)

func listMidiCmds(args, sender):
	if !args.empty():
		reportError("listMidiCmds expects no arguments", sender)
		return
	var midiCmds = midiNode.listCmds()
	reportStatus(midiCmds, sender)

############################################################
# Randomness commands
############################################################
# set a random value (in a range) for a command argument
func randCmdArg(inArgs, sender):
	if len(inArgs) != 4:
		reportError("randCmdArg expected 4 arguments: num arguments - %d" % [len(inArgs)], sender)
		return
	var cmd = inArgs[0]
	# need to get different values with wildcard actors
	var aa = getActorsAndArgs(inArgs.slice(1,-1), "randCmdArg", 2, sender)
	for actor in aa.actors:
		var value = rand_range(float(aa.args[0]), float(aa.args[1]))
		main.evalCommandList([[cmd, actor.name, value]], sender)

func chooseCmd(inArgs, sender):
	var cmds : Array
	var last = 0
	for i in len(inArgs):
		if inArgs[i] == ",":
			cmds.push_back(inArgs.slice(last, i-1))
			last = i+1
		if i == len(inArgs) - 1:
			cmds.push_back(inArgs.slice(last, -1))
	Logger.debug("choose cmd: %s" % [cmds])
	var randIndex = randi() % len(cmds)
	var cmd = cmds[randIndex]
	Logger.debug("chosen cmd: %s" % [cmd])
	main.evalCommandList([cmd], sender)

# choose a random value from the list for a command argument
func chooseArg(inArgs, sender):
	if len(inArgs) < 2:
		reportError("chooseCmdArg expected at least 2 arguments: num arguments - %d" % [len(inArgs)], sender)
		return
	var cmd = inArgs[0]
	var actor = inArgs[1]
	var args = inArgs.slice(2, -1)
	var argi = randi() % len(args)
	var arg = args[argi]
	Logger.debug("cmd:%s actor:%s args:%s arg:%s" % [cmd, actor, args, arg])
	Logger.debug("Chose argument: %s" % [arg])
	main.evalCommandList([[cmd, actor, arg]], sender)

############################################################
# Routine commands
############################################################
func newRoutine(args, sender):
	# /routine name wait repeats cmd
	if len(args) < 4:
		reportError("cmdsRoutine expects at least 3 arguments. %d given" % [len(args)], sender)
		return
	Logger.verbose("new routine: %s" % [args])
	
	var name = args[0]
	var routine
	if routinesNode.has_node(name):
		routine = routinesNode.get_node(name)
	else:
		routine = routineNode.instance()
		routine.name = name
		routinesNode.add_child(routine)
	routine.setRepeats(args[1])
	routine.wait_time = float(args[2])
	routine.cmd = args.slice(3,-1)
	routine.start()

func startRoutine(args, sender):
	if len(args) < 1:
		reportError("cmdsRoutine expects 1 argument. %d given" % [len(args)], sender)
		return
	routinesNode.get_node(args[0]).start()
	
func stopRoutine(args, sender):
	if len(args) < 1:
		reportError("cmdsRoutine expects 1 argument. %d given" % [len(args)], sender)
		return
	routinesNode.get_node(args[0]).stop()

func freeRoutine(args, sender):
	if len(args) < 1:
		reportError("cmdsRoutine expects 1 argument. %d given" % [len(args)], sender)
		return
	var name = args[0]
	if routinesNode.has_node(name):
		var routine = routinesNode.get_node(name)
		routine.stop()
		routine.remove_and_skip()
		Logger.verbose("free routine %s" % [name])
	else:
		reportError("Routine not found: %s" % [name], sender)

func listRoutines(args, sender):
	if len(args) < 0:
		reportError("cmdsRoutine expects 0 arguments. %d given" % [len(args)], sender)
		return
	var routines : Dictionary
	var routinesListStr : String
	for routine in routinesNode.get_children():
		routines[routine.name] = routine.cmd
		var intervalStr : String
		if routine.repeats == 0: 
			intervalStr = "inf"
		else:
			intervalStr = "%d times" % [routine.repeats]
		var statusStr : String
		if routine.is_stopped():
			statusStr = "stopped"
		else:
			statusStr = "running"
		routinesListStr += "\n%s (%s) %d times every %.2f: %s" % [routine.name, statusStr, routine.repeats, routine.wait_time, " ".join(routine.cmd)]
	reportStatus("routines: %s" % [routinesListStr], sender)

############################################################
# Frame commands
############################################################
func onFrameActor(inArgs, sender):
	if len(inArgs) < 4:
		reportError("onFrameActor expects at least 4 arguments: given %s" % [len(inArgs)], sender)
		return
	# this is a hack to overcome the argument limit. We want it to check for minimum number
	# of arguments, not the exact one
	var aa = getActorsAndArgs(inArgs, "onFrameActor", len(inArgs)-1, sender)
	if aa:
		for actor in aa.actors:
			var frame = inArgs[1]
			var cmd = aa.args.slice(1, -1)
			actor.addCmdToSequence(frame, cmd)

func onFrameFreeActor(inArgs, sender):
	var aa = getActorsAndArgs(inArgs, "onFrameFreeActor", 3, sender)
	if aa:
		for actor in aa.actors:
			var frame = inArgs[1]
			var cmd = aa.args.slice(1, -1)
			actor.removeCmdFromSequence(frame, cmd)

func onFinishActor(inArgs, sender):
	var aa = getActorsAndArgs(inArgs, "onFrameActor", null, sender)
	if aa:
		for actor in aa.actors:
			var cmd = aa.args.slice(0, -1)
			actor.addFinishCmd(cmd)

func onFinishFreeActor(inArgs, sender):
	var aa = getActorsAndArgs(inArgs, "onFinishFreeActor", null, sender)
	if aa:
		for actor in aa.actors:
			var cmd = aa.args
			actor.removeFinishCmd(cmd)

func getSequenceActor(inArgs, sender):
	reportError("TODO getSequenceActor", sender)
	var aa = getActorsAndArgs(inArgs, "getSequenceActor", 0, sender)
	if aa:
		for actor in aa.actors:
			actor.listSequenceCmds()
