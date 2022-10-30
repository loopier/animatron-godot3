extends KinematicBody2D

# store commands for different frequency bands
var soundCmds : Array
var main

func addSoundCmd( band, cmd, minVal, maxVal ):
	soundCmds[band].append([cmd, minVal, maxVal])
	print(soundCmds)

func removeSoundCmd( band ):
	soundCmds[band] = null
	print(soundCmds)

func _on_AudioInputPlayer_sound_changed(band, amp):
#	print(band, ":", amp)
	if not get_parent():
		return
	var main = get_parent().get_parent()
	var cmds = soundCmds[band]
	
	for cmd in cmds:
		var addr = cmd[0]
		if not addr.begins_with("/"):
			addr = "/" + addr
		main.evalOscCommand(addr, [name, amp], null)

func _ready():
	main = get_parent().get_parent()
	for i in range(main.get_node("AudioInputPlayer").VU_COUNT):
		var cmds : Array
		soundCmds.append(cmds)

