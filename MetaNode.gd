extends KinematicBody2D

var sequence : Dictionary
var finishCmds : Dictionary
var sequenceIndex = 0
# frame that triggers the next command in the sequence
var trigFrame = 0
var main


func _ready():
	var animNode = get_node("Offset/Animation")
	animNode.connect("frame_changed", self, "_on_Animation_frame_changed")
	animNode.connect("animation_finished", self, "_on_Animation_animation_finished")

func _on_Animation_frame_changed():
	main = get_parent()
	if main == null:
		return
	main = main.get_parent()
	var anim = get_node("Offset/Animation").get_animation()
	var frame = get_node("Offset/Animation").get_frame()
	if sequence.has(frame):
		sendCmds(frame)

func _on_Animation_animation_finished():
	for cmd in finishCmds:
		main.evalOscCommand(finishCmds[cmd][0], finishCmds[cmd].slice(1,-1), null)

func resetSequence():
	sequenceIndex = 0

func addCmdToSequence( inframe, cmd ):
	var anim = get_node("Offset/Animation").get_animation()
#	print("%s:%s %s:%s" % [typeof frame, frame, typeof cmd, cmd])
	var numframes = get_node("Offset/Animation").get_sprite_frames().get_frame_count(anim)
#	print("%s/%s: %s %s" % [inframe, numframes, cmd, anim])
	trigFrame = int(inframe) % numframes
	
	var key = getKey(cmd)
	if sequence.has(trigFrame):
		sequence[trigFrame][key] = cmd
	else:
		sequence[trigFrame] = {key: cmd}
	
	print("add cmd to sequence on frame %d: %s" % [trigFrame, cmd])
	print(sequence)
	return sequence

func removeCmdFromSequence( inframe, cmd ):
	print("remove cmd for frame %s: %s" % [inframe, cmd])
	var reply
	var key = getKey(cmd)
	inframe = int(inframe)
	
	if sequence.has(inframe):
		sequence[inframe].erase(key)
		reply = sequence[inframe]
		if len(sequence[inframe]) == 0:
			sequence.erase(inframe)
	else:
		# TODO: change to send '/report/error'
		reply = "Command not found in trigger frame %d: %s" % [inframe, cmd]
	print(reply)
	return reply

func addFinishCmd( cmd ):
	var key = getKey(cmd)
	finishCmds[key] = cmd
	print("add onfinish cmd: %s : %s" % [key, cmd])
	print("on finish: ", finishCmds)

func removeFinishCmd( cmd ):
	print(cmd)
	var key = getKey(cmd)
	if finishCmds.has(key):
		finishCmds.erase(key)
	print("remove  cmd: %s : %s" % [key, cmd])
	print("on finish: ", finishCmds)

func getSequence():
	return sequence

func getKey( cmd ):
	if len(cmd) > 1:
		return "%s/%s" % [cmd[0], cmd[1]]
	return cmd[0]

func sendCmds( inframe ):
	for cmd in sequence[inframe]:
		var addr = sequence[inframe][cmd][0]
		var args = sequence[inframe][cmd].slice(1,-1)
#		print("sending %s to %s" % [sequence[inframe][cmd], main])
#		print("cmd:%s args:%s" % [addr, args])
		main.evalOscCommand(addr, args, null)

func listSequenceCmds():
	print("frame commands for %s:\n%s" % [name,sequence])
	print("finish commands for %s:\n%s" % [name,finishCmds])
