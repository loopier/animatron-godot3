extends KinematicBody2D

# store commands for different frequency bands
var soundCmds : Array
var midiNoteOnCmds
var midiNoteOffCmds
var midiCcCmds
var main

func addSoundCmd( band, cmd, minVal, maxVal ):
	soundCmds[min(band, len(soundCmds)-1)][cmd] = [minVal, maxVal]
	print(soundCmds)

func removeSoundCmd( band ):
	soundCmds[min(band, len(soundCmds)-1)] = {}
	print(soundCmds)

func addMidiNoteOnCmd( cmd, minVal, maxVal ):
	midiNoteOnCmds[cmd] = [minVal, maxVal]
	print(midiNoteOnCmds)
	
func addMidiNoteOffCmd( cmd, minVal, maxVal ):
	midiNoteOffCmds[cmd] = [minVal, maxVal]
	print(midiNoteOffCmds)
	
func addMidiCcCmd( cmd, minVal, maxVal ):
	midiCcCmds[cmd] = [minVal, maxVal]
	print(midiCcCmds)

func removeMidiNoteOnCmd( cmd ):
	midiNoteOnCmds.erase(cmd)
	print(midiNoteOnCmds)

func removeMidiNoteOffCmd( cmd ):
	midiNoteOffCmds.erase(cmd)
	print(midiNoteOffCmds)

func removeMidiCcCmd( cmd ):
	midiCcCmds.erase(cmd)
	print(midiCcCmds)

func _on_AudioInputPlayer_sound_changed(band, amp):
#	print(band, ":", amp)
	if not get_parent():
		return
	var main = get_parent().get_parent()
	var cmds = soundCmds[band]
	eventToOsc(soundCmds[band], amp, 0.0, 1.0)

# TODO: 'velocity' is unused 
func _on_Midi_note_on_received(num, velocity):
	eventToOsc(midiNoteOnCmds, num, 0, 127)

func _on_Midi_note_off_received(num, val):
	eventToOsc(midiNoteOffCmds, num, 0, 127)
	
func _on_Midi_cc_received(num, val):
	eventToOsc(midiCcCmds, num, 0, 127)
	
func _ready():
	main = get_parent().get_parent()
	# VU_COUNT is declared in AudioInputPlayer.gd
	for i in range(main.get_node("AudioInputPlayer").VU_COUNT):
		soundCmds.append({})
	midiNoteOnCmds = {}
	midiNoteOffCmds = {}
	midiCcCmds = {}

func eventToOsc(cmdsList, value, inmin, inmax):
	if not get_parent():
		return
	var main = get_parent().get_parent()
	for addr in cmdsList.keys():
		if not addr.begins_with("/"):
			addr = "/" + addr
		var minval = cmdsList[addr][0]
		var maxval = cmdsList[addr][1]
		value  = linlin(value, inmin, inmax, minval, maxval)
#		print(value)
		main.evalOscCommand(addr, [name, value], null)
		

func linlin(val, inmin, inmax, outmin, outmax):
#	var x = float(val - inmin) / float(inmax - inmin)
#	print("(%d - %d) / (%d - %d) = %f" % [val, inmin, inmax, inmin, x])
#	print("%s %s %s %s %s" % [val, inmin, inmax, outmin, outmax])
	return (float(val - inmin) / float(inmax - inmin)) * float(outmax - outmin) + outmin
