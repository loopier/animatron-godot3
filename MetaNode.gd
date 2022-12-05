extends KinematicBody2D

var sequence : Array
var sequenceIndex = 0
# frame that triggers the next command in the sequence
var trigFrame = 0


func _ready():
	var animNode = get_node("Offset/Animation")
	animNode.connect("frame_changed", self, "_on_Animation_frame_changed")
	animNode.connect("animation_finished", self, "_on_Animation_animation_finished")

func _on_Animation_frame_changed():
	var anim = get_node("Offset/Animation").get_animation()
	var frame = get_node("Offset/Animation").get_frame()
	if frame == trigFrame:
		var nextTrig = sequence[sequenceIndex][0]
		var cmd = sequence[sequenceIndex][1]
		trigFrame = nextTrig
		sequenceIndex = (sequenceIndex + 1) % len(sequence)
		
		print("sequence index for %s @ %d: %d - frame:%d trig:%d cmd:%s" % [name, trigFrame, sequenceIndex, frame, nextTrig, cmd])
	

func _on_Animation_animation_finished():
#	print("finished: %s" % [name])
	pass

func resetSequence():
	sequenceIndex = 0

func addCmdToSequence( frame, cmd ):
	var anim = get_node("Offset/Animation").get_animation()
	var trigFrame = frame % get_node("Offset/Animation").get_sprite_frames().get_frame_count(anim)
	sequence.append([trigFrame, cmd])
	print(getKey(frame, cmd))
	
	print("add sequence: onframe:%d cmd:%s" % [trigFrame, cmd])
	print(sequence)

func removeCmdFromSequence( frame ):
	print("remove cmd for frame: %d" % [frame])

func getSequence():
	return sequence

func getKey( frame, cmd ):
	return "%s%s/%s" % [frame, cmd[0], cmd[1]]
