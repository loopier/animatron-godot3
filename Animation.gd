extends AnimatedSprite

var random = false setget setRandom
var loopStart := 0 setget setStart
var loopEnd := -1 setget setEnd
var reverse := false

func _ready():
	connect("frame_changed", self, "_on_Animation_frame_changed")

func _on_Animation_animation_finished():
	if not reverse:
		frame = loopStart
	else:
		frame = loopEnd
	
	# we need to manually stop the animation if the last frame of the range is
	# not the last frame the animation (loopEnd != last frame)
	if not frames.get_animation_loop(animation):
		stop()
		frame = loopEnd if not reverse else loopStart

func _on_Animation_frame_changed():
#	Logger.debug("play:%s frame:%s loop:%s start:%s end:%s speed:%s" % [is_playing(), frame, loop, loopStart, loopEnd, frames.get_animation_speed(animation)])
	if random:
		set_frame( randi() % frames.get_frame_count( animation ) )
	
	if loopEnd < 0:
		loopEnd = frames.get_frame_count(animation) - 1
	
#	Logger.debug("loop end: %s" % [reverse])
	if not reverse and frame > loopEnd:
		emit_signal("animation_finished")
	if reverse and frame < loopStart or frame > loopEnd:
		emit_signal("animation_finished")

func setSpeed(speed):
	if float(speed) < 0:
		reverse = true
	else:
		reverse = false
	play("", reverse)
	set_speed_scale(abs(float(speed)))

func loop(loop):
	frames.set_animation_loop(animation, loop)
	play("", reverse)

func setRandom(newRandom):
	random = newRandom
	if random and not is_playing():
		play()

func setRange(startFrame, endFrame):
	loopStart = int(startFrame)
	loopEnd = int(endFrame)
	if frame < loopStart:
		frame = loopStart
	if frame > endFrame:
		endFrame
#	frame = loopStart if not reverse else loopEnd

func setStart(startFrame):
	loopStart = int(startFrame)

func setEnd(endFrame):
	loopEnd = int(endFrame)
