extends AnimatedSprite

var loop = true setget setLoop
var random = false setget setRandom

func _ready():
	connect("frame_changed", self, "_on_Animation_frame_changed")

func _on_Animation_animation_finished():
#	print("animation finished: %s" % get_owner().get_name())
	if not loop:
		stop()

func _on_Animation_frame_changed():
#	print("animation frame %s" % get_frame())
	if random:
		set_frame( randi() % frames.get_frame_count( animation ) )



func setLoop(newLoop):
	loop = newLoop
	if loop and not is_playing():
		play()

func setRandom(newRandom):
	random = newRandom
	print("random '{}': {}".format([get_owner().get_name(), random], "{}"))
	if random and not is_playing():
		play()
