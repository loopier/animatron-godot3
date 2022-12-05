class_name Midi
extends Node

signal note_on_received(num, velocity, ch)
signal note_off_received(num, velocity, ch)
signal cc_received(num, value, ch)

var debug = true

# MIDI message mapping
# --------------------
# NOTEON and NOTEOFF events can be mapped in 2 different ways;
# they can send a differen tcommand PER NOTE or the same command for ALL NOTES:
#
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

# Called when the node enters the scene tree for the first time.
func _ready():
	OS.open_midi_inputs()
	print("MIDI devices: ",OS.get_connected_midi_inputs())
	
	midiAnyNoteOnCmds = {}
	midiAnyNoteOffCmds = {}
	for i in range(128):
		midiNoteOnCmds.append({})
		midiNoteOffCmds.append({})
		midiCcCmds.append({})
	
	connect("note_on_received", self, "_on_Midi_note_on_received")
	connect("note_off_received", self, "_on_Midi_note_off_received")
	connect("cc_received", self, "_on_Midi_cc_received")
	set_process_unhandled_input(true)

func enableDebug(enable):
	debug = enable

func _unhandled_input(event):
	if(event is InputEventMIDI):
		var signalMsg = ""
		var num = 0
		var value = 0
#		print("MIDI: ", event.as_text())
#		print("MIDI:", event.message)
#		print("MSG:", MIDI_MESSAGE_CONTROL_CHANGE)
		var msg =  "ch:" + str(event.get_channel()) + " note:" + str(event.get_pitch()) + " vel:" + str(event.get_velocity()) + " inst:" + str(event.get_instrument()) + " pres:" + str(event.get_pressure()) + " cc#:" + str(event.get_controller_number()) + " ccv:" + str(event.get_controller_value())
#		print(msg)
		if event.message == MIDI_MESSAGE_NOTE_ON:
				signalMsg = "note_on_received"
				num = event.get_pitch()
				value = event.get_velocity()
		elif event.message == MIDI_MESSAGE_NOTE_OFF:
				signalMsg = "note_off_received"
				num = event.get_pitch()
				value = event.get_velocity()
		elif event.message == MIDI_MESSAGE_CONTROL_CHANGE:
				signalMsg = "cc_received"
				num = event.get_controller_number()
				value = event.get_controller_value()
		
		if debug:
			print("MIDI msg: %s - num:%d - val:%d - ch:%d" % [signalMsg, num, value, event.get_channel()])
#		print("signal: %s %d %d %d" % [signalMsg, num, value, event.get_channel()])
		emit_signal(signalMsg, num, value, event.get_channel())

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


func setMidiChannel( ch ):
	midiChannel = ch
	print("'%s' listening to MIDI channel: %d" % [name, midiChannel])

func addMidiAnyNoteOnCmd( cmd, actor, minVal, maxVal ):
	var key = getKey(cmd, actor)
	midiAnyNoteOnCmds[key] = {"addr":cmd, "actor":actor, "value":[minVal, maxVal]}
	print(midiAnyNoteOnCmds)

func addMidiAnyNoteOffCmd( cmd, actor, minVal, maxVal ):
	var key = getKey(cmd, actor)
	midiAnyNoteOffCmds[key] = {"addr":cmd, "actor":actor, "value":[minVal, maxVal]}
	print(midiAnyNoteOffCmds)

func addMidiNoteOnCmd( num, cmd, actor, minVal, maxVal ):
	var key = getKey(cmd, actor)
	midiNoteOnCmds[num][key] = {"addr":cmd, "actor":actor, "value":[minVal, maxVal]}
	print(midiNoteOnCmds)

func addMidiNoteOffCmd( num, cmd, actor, minVal, maxVal ):
	var key = getKey(cmd, actor)
	midiNoteOffCmds[num][key] = {"addr":cmd, "actor":actor, "value":[minVal, maxVal]}
	print(midiNoteOffCmds)

func addMidiCcCmd( cc, cmd, actor, minVal, maxVal ):
	var key = getKey(cmd, actor)
	midiCcCmds[cc][key] = {"addr":cmd, "actor":actor, "value":[minVal, maxVal]}
#	print("cc:%d cmd:%s min:%f max:%f" % [cc, cmd, actor, minVal, maxVal])
	print(midiCcCmds)

func addMidiVelocityCmd( cmd, actor, minVal, maxVal ):
	for i in range(128):
		addMidiNoteOnCmd(i, cmd, actor, minVal, maxVal)
#	print(midiNoteOnCmds)

func removeMidiAnyNoteOnCmd( cmd, actor ):
	var key = getKey(cmd, actor)
	midiAnyNoteOnCmds.erase(key)
	print(midiAnyNoteOnCmds)

func removeMidiAnyNoteOffCmd( cmd, actor ):
	var key = getKey(cmd, actor)
	midiAnyNoteOffCmds.erase(key)
	print(midiAnyNoteOffCmds)
	
func removeMidiNoteOnCmd( num, cmd, actor ):
	var key = getKey(cmd, actor)
	midiNoteOnCmds[num].erase(key)
	print(midiNoteOnCmds)

func removeMidiNoteOffCmd( num, cmd, actor ):
	var key = getKey(cmd, actor)
	midiNoteOffCmds[num].erase(key)
	print(midiNoteOffCmds)

func removeMidiCcCmd( num, cmd, actor ):
	var key = getKey(cmd, actor)
	midiCcCmds[num].erase(key)
	print(midiCcCmds)

func removeMidiVelocityCmd( cmd, actor ):
	for i in range(128):
		removeMidiNoteOnCmd(i, cmd, actor)
	print(midiNoteOnCmds)


func eventToOsc(cmdsList, value, inmin, inmax):
	if not get_parent():
		return
	var main = get_parent()
	for key in cmdsList.keys():
		var addr = cmdsList[key]["addr"]
		if not addr.begins_with("/"):
			addr = "/" + addr
		var actor = cmdsList[key]["actor"].name
		var minval = cmdsList[key]["value"][0]
		var maxval = cmdsList[key]["value"][1]
		value  = Helper.linlin(value, inmin, inmax, minval, maxval)
#		print("sending msg from MIDI: %s %s %f" % [addr, actor, value])
		main.evalOscCommand(addr, [actor, value], null)

func getKey(cmd, actor):
	return "%s/%s" % [cmd, actor.name]
