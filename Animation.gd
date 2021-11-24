extends AnimatedSprite

var loop = true setget setLoop


func _on_Animation_animation_finished():
	if not loop:
		stop()


func setLoop(newLoop):
	loop = newLoop
	if loop and not is_playing():
		play()
