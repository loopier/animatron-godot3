extends AnimatedSprite

var loop = true setget setLoop
var random = false setget setRandom
var loopStart := 0 setget setStart
var loopEnd := 0 setget setEnd
var reverse := false

func _ready():
	connect("frame_changed", self, "_on_Animation_frame_changed")
	loopEnd = frames.get_frame_count(animation)

func _on_Animation_animation_finished():
#	Logger.debug("finished:%s" % [get_parent().get_parent().name])
	if not loop:
		stop()

func _on_Animation_frame_changed():
#	Logger.debug("play:%s frame:%s loop:%s start:%s end:%s speed:%s" % [is_playing(), frame, loop, loopStart, loopEnd, frames.get_animation_speed(animation)])
	if random:
		set_frame( randi() % frames.get_frame_count( animation ) )
	if is_playing() and loop:
		if not reverse and frame > loopEnd:
			frame = loopStart
			emit_signal("animation_finished")
		if reverse and frame < loopStart:
			frame = loopEnd
			emit_signal("animation_finished")

func setSpeed(speed):
	if float(speed) < 0:
		reverse = true
	else:
		reverse = false
	play("", reverse)
	set_speed_scale(abs(float(speed)))

func setLoop(newLoop):
	loop = newLoop
	if loop and not is_playing():
		play()

func setRandom(newRandom):
	random = newRandom
	print("random '{}': {}".format([get_owner().get_name(), random], "{}"))
	if random and not is_playing():
		play()

func setRange(startFrame, endFrame):
	loopStart = int(startFrame)
	loopEnd = int(endFrame)

func setStart(startFrame):
	loopStart = int(startFrame)

func setEnd(endFrame):
	loopEnd = int(endFrame)
