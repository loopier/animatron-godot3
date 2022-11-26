extends KinematicBody2D

# store commands for different frequency bands
var soundCmds : Array

# while NOTEON and NOTEOFF events trigger commands, using note NUMBER as the
# argument's value (leaving VELOCITY unused), on CC the NUMBER is what triggers
# the commands, and the VALUE is passed as argument.
# So MIDI NOTEON/OFF events are dictionaries, while CC events is an array of
# dictionaries (each dictionary being a list of commands to be triggered).
var midiNoteOnCmds
var midiNoteOffCmds
var midiCcCmds : Array
var midiChannel = 0
var main

func addSoundCmd( band, cmd, minVal, maxVal ):
	soundCmds[min(band, len(soundCmds)-1)][cmd] = [minVal, maxVal]
	print(soundCmds)

func removeSoundCmd( band ):
	soundCmds[min(band, len(soundCmds)-1)] = {}
	print(soundCmds)

func setMidiChannel( ch ):
	midiChannel = ch
	print("'%s' listening to MIDI channel: %d" % [name, midiChannel])

func addMidiNoteOnCmd( cmd, minVal, maxVal ):
	midiNoteOnCmds[cmd] = [minVal, maxVal]
	print(midiNoteOnCmds)
	
func addMidiNoteOffCmd( cmd, minVal, maxVal ):
	midiNoteOffCmds[cmd] = [minVal, maxVal]
	print(midiNoteOffCmds)
	
func addMidiCcCmd( cc, cmd, minVal, maxVal ):
	midiCcCmds[cc][cmd] = [minVal, maxVal]
#	print("cc:%d cmd:%s min:%f max:%f" % [cc, cmd, minVal, maxVal])
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
func _on_Midi_note_on_received(num, velocity, ch):
	if ch != midiChannel:
		return
	eventToOsc(midiNoteOnCmds, num, 0, 127)

func _on_Midi_note_off_received(num, val, ch):
	if ch != midiChannel:
		return
	eventToOsc(midiNoteOffCmds, num, 0, 127)
	
func _on_Midi_cc_received(num, val, ch):
	print("%d %d %d" % [num, val, ch])
	if ch != midiChannel:
		return
	eventToOsc(midiCcCmds[num], val, 0, 127)
	
func _ready():
	main = get_parent().get_parent()
	# VU_COUNT is declared in AudioInputPlayer.gd
	for i in range(main.get_node("AudioInputPlayer").VU_COUNT):
		soundCmds.append({})
	midiNoteOnCmds = {}
	midiNoteOffCmds = {}
	for i in range(127):
		midiCcCmds.append({})

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
