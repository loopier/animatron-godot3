extends KinematicBody2D

var sequence : Dictionary
var sequenceIndex = 0
# frame that triggers the next command in the sequence
var trigFrame = 0
var main


func _ready():
	var animNode = get_node("Offset/Animation")
	animNode.connect("frame_changed", self, "_on_Animation_frame_changed")
	animNode.connect("animation_finished", self, "_on_Animation_animation_finished")

func _on_Animation_frame_changed():
	main = get_parent().get_parent()
	var anim = get_node("Offset/Animation").get_animation()
	var frame = get_node("Offset/Animation").get_frame()
	if sequence.has(frame):
		sendCmds(frame)

func _on_Animation_animation_finished():
#	print("finished: %s" % [name])
	pass

func resetSequence():
	sequenceIndex = 0

func addCmdToSequence( inframe, cmd ):
	var anim = get_node("Offset/Animation").get_animation()
#	print("%s:%s %s:%s" % [typeof frame, frame, typeof cmd, cmd])
#	print("%s:%s %s" % [frame, cmd, anim])
	if inframe < 0:
		trigFrame = get_node("Offset/Animation").get_sprite_frames().get_frame_count(anim) - 1
	else:
		trigFrame = inframe % get_node("Offset/Animation").get_sprite_frames().get_frame_count(anim)
	
	var key = getKey(cmd)
	if sequence.has(trigFrame):
		sequence[trigFrame][key] = cmd
	else:
		sequence[trigFrame] = {key: cmd}
	
	print("add cmd to sequence on frame %d: %s" % [trigFrame, cmd])
	print(sequence)
	return sequence

func removeCmdFromSequence( inframe, cmd ):
	print("remove cmd for frame %d: %s" % [inframe, cmd])
	var reply
	var key = getKey(cmd)
	var anim = get_node("Offset/Animation").get_animation()
	if inframe < 0:
		inframe = get_node("Offset/Animation").get_sprite_frames().get_frame_count(anim) - 1
	print("inframe: ", inframe)
	if sequence.has(inframe):
		sequence[inframe].erase(key)
		reply = sequence[inframe]
	else:
		# TODO: change to send '/report/error'
		reply = "Command not found in trigger frame %d: %s" % [inframe, cmd]
	print(reply)
	return reply

func getSequence():
	return sequence

func getKey( cmd ):
	return "%s/%s" % [cmd[0], cmd[1]]

func sendCmds( inframe ):
	for cmd in sequence[inframe]:
		var addr = sequence[inframe][cmd][0]
		var args = sequence[inframe][cmd].slice(1,-1)
#		print("sending %s to %s" % [sequence[inframe][cmd], main])
#		print("cmd:%s args:%s" % [addr, args])
		main.evalOscCommand(addr, args, null)

func listSequenceCmds():
	print("frame commands for %s:\n%s" % [name,sequence])
