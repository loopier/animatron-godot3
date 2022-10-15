extends AnimatedSprite

var loop = true setget setLoop


func _on_Animation_animation_finished():
	if not loop:
		stop()
	get_node("/root/Events").emit_signal("animation_finished", self.get_owner().get_name())


func setLoop(newLoop):
	loop = newLoop
	if loop and not is_playing():
		play()
