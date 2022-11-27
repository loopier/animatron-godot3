extends KinematicBody2D

# store commands for different frequency bands
var soundCmds : Array

# MIDI message mapping
# --------------------
# NOTEON and NOTEOFF events can be mapped in 2 different ways:
# - midiNoteOnCmd/midiNoteOffCmd: DIFFERENT NOTENUM send DIFFERENT COMMANDS, 
# using VELOCITY as the command argument
# - midiAnyNoteOnCmd/midiAnyNoteOffCmd: DIFFERENT NOTENUM send the SAME COMMANDS, 
# using NOTENUM as the command argument discarding VELOCITY

# CC events are mapped so that DIFFERENT CCNUM send DIFFERENT COMMANDS, using
# VALUE as command argument

# Signals
# -------
# WARNING: MIDI signals are connected the first time a MIDI event is mapped. But
#          they are NEVER explicitly disconnected. I'm not sure if this affects
#          the performance. If it does, signals should be disconnected when
#          BOTH midiNoteOnCmds (singular) and midiAnyNoteOnCmd (plural) arrays
#          are empty (same for *noteOff*).

var midiAnyNoteOnCmds
var midiAnyNoteOffCmds
var midiNoteOnCmds : Array
var midiNoteOffCmds : Array
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

func addMidiAnyNoteOnCmd( cmd, minVal, maxVal ):
	midiAnyNoteOnCmds[cmd] = [minVal, maxVal]
	print(midiAnyNoteOnCmds)
	
func addMidiAnyNoteOffCmd( cmd, minVal, maxVal ):
	midiAnyNoteOffCmds[cmd] = [minVal, maxVal]
	print(midiAnyNoteOffCmds)
	
func addMidiNoteOnCmd( num, cmd, minVal, maxVal ):
	midiNoteOnCmds[num][cmd] = [minVal, maxVal]
	print(midiNoteOnCmds)
	
func addMidiNoteOffCmd( num, cmd, minVal, maxVal ):
	midiNoteOffCmds[num][cmd] = [minVal, maxVal]
	print(midiNoteOffCmds)
	
func addMidiCcCmd( cc, cmd, minVal, maxVal ):
	midiCcCmds[cc][cmd] = [minVal, maxVal]
#	print("cc:%d cmd:%s min:%f max:%f" % [cc, cmd, minVal, maxVal])
	print(midiCcCmds)

func addMidiVelocityCmd( cmd, minVal, maxVal ):
	for i in range(128):
		addMidiNoteOnCmd(i, cmd, minVal, maxVal)
#	print(midiNoteOnCmds)

func removeMidiAnyNoteOnCmd( cmd ):
	midiAnyNoteOnCmds.erase(cmd)
	print(midiAnyNoteOnCmds)

func removeMidiAnyNoteOffCmd( cmd ):
	midiAnyNoteOffCmds.erase(cmd)
	print(midiAnyNoteOffCmds)
	
func removeMidiNoteOnCmd( num, cmd ):
	midiNoteOnCmds[num].erase(cmd)
	print(midiNoteOnCmds)

func removeMidiNoteOffCmd( num, cmd ):
	midiNoteOffCmds[num].erase(cmd)
	print(midiNoteOffCmds)

func removeMidiCcCmd( num, cmd ):
	midiCcCmds[num].erase(cmd)
	print(midiCcCmds)

func removeMidiVelocityCmd( cmd ):
	for i in range(128):
		removeMidiNoteOnCmd(i, cmd)
#	print(midiNoteOnCmds)

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
	eventToOsc(midiAnyNoteOnCmds, num, 0, 127)
	eventToOsc(midiNoteOnCmds[num], velocity, 0, 127)

func _on_Midi_note_off_received(num, velocity, ch):
	if ch != midiChannel:
		return
	eventToOsc(midiAnyNoteOffCmds, num, 0, 127)
	eventToOsc(midiNoteOffCmds[num], velocity, 0, 127)
	
func _on_Midi_cc_received(num, val, ch):
	if ch != midiChannel:
		return
	eventToOsc(midiCcCmds[num], val, 0, 127)
	
func _ready():
	main = get_parent().get_parent()
	# VU_COUNT is declared in AudioInputPlayer.gd
	for i in range(main.get_node("AudioInputPlayer").VU_COUNT):
		soundCmds.append({})
	midiAnyNoteOnCmds = {}
	midiAnyNoteOffCmds = {}
	for i in range(128):
		midiNoteOnCmds.append({})
		midiNoteOffCmds.append({})
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
		print("sending msg from MIDI: %s %f" % [addr, value])
		main.evalOscCommand(addr, [name, value], null)
		

func linlin(val, inmin, inmax, outmin, outmax):
#	var x = float(val - inmin) / float(inmax - inmin)
#	print("(%d - %d) / (%d - %d) = %f" % [val, inmin, inmax, inmin, x])
#	print("%s %s %s %s %s" % [val, inmin, inmax, outmin, outmax])
	return (float(val - inmin) / float(inmax - inmin)) * float(outmax - outmin) + outmin
