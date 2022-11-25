extends KinematicBody2D

# store commands for different frequency bands
var soundCmds : Array
var main

func addSoundCmd( band, cmd, minVal, maxVal ):
	soundCmds[min(band, len(soundCmds)-1)][cmd] = [minVal, maxVal]
	print(soundCmds)

func removeSoundCmd( band ):
	soundCmds[min(band, len(soundCmds)-1)] = {}
	print(soundCmds)

func _on_AudioInputPlayer_sound_changed(band, amp):
#	print(band, ":", amp)
	if not get_parent():
		return
	var main = get_parent().get_parent()
	var cmds = soundCmds[band]
	
	for addr in cmds.keys():
		if not addr.begins_with("/"):
			addr = "/" + addr
		var minval = soundCmds[band][addr][0]
		var maxval = soundCmds[band][addr][1]
		
		# linlin() is a helper function declared below
		amp = linlin(amp, 0.0, 1.0, minval, maxval)
		main.evalOscCommand(addr, [name, amp], null)

func _ready():
	main = get_parent().get_parent()
	# VU_COUNT is declared in AudioInputPlayer.gd
	for i in range(main.get_node("AudioInputPlayer").VU_COUNT):
		soundCmds.append({})

func linlin(val, inmin, inmax, outmin, outmax):
	return (val - inmin) / (inmax - inmin) * (outmax - outmin) + outmin
