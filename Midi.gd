class_name Midi
extends Node

signal note_on_received(num, velocity, ch)
signal note_off_received(num, velocity, ch)
signal cc_received(num, value, ch)

var debug = true
var midiCmds : Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	OS.open_midi_inputs()
	print("MIDI devices: ",OS.get_connected_midi_inputs())	
	set_process_unhandled_input(true)

func enableDebug(enable):
	debug = enable

func _unhandled_input(event):
	if(event is InputEventMIDI):
		var signalMsg = ""
		var ch = event.get_channel()
		var num = 0
		var value = 0
#		print("MIDI: ", event.as_text())
#		print("MIDI:", event.message)
#		print("MSG:", MIDI_MESSAGE_CONTROL_CHANGE)
#		var msg =  "ch:" + str(ch) + " note:" + str(event.get_pitch()) + " vel:" + str(event.get_velocity()) + " inst:" + str(event.get_instrument()) + " pres:" + str(event.get_pressure()) + " cc#:" + str(event.get_controller_number()) + " ccv:" + str(event.get_controller_value())
#		print(msg)
		if event.message == MIDI_MESSAGE_NOTE_ON:
				signalMsg = "noteon"
				num = event.get_pitch()
				value = event.get_velocity()
		elif event.message == MIDI_MESSAGE_NOTE_OFF:
				signalMsg = "noteoff"
				num = event.get_pitch()
				value = event.get_velocity()
		elif event.message == MIDI_MESSAGE_CONTROL_CHANGE:
				signalMsg = "cc"
				num = event.get_controller_number()
				value = event.get_controller_value()
		
		if debug:
			print("MIDI msg: %s - ch: %d - num:%d - val:%d - ch:%d" % [signalMsg, ch, num, value, event.get_channel()])

		if signalMsg == "":
			return
		
		processMidiCmd(signalMsg, ch, num, value)

func addMidiCmd( event, ch, num, cmd, actor, minVal, maxVal ):
	if String(num) == "*":
		for i in range(128):
			# to map any note midievent to a command, we need to
			# map use note number as velocity value, so we pass
			# the same value for both min and max
			if minVal == null: minVal = i + 1
			if maxVal == null: maxVal = i + 1
			var newMinVal = Helper.linlin(i, 0,127, minVal, maxVal)
			var newMaxVal = newMinVal
			addMidiCmd(event, ch, i, cmd, actor, newMinVal, newMaxVal)
		return
	var key = "%s/ch%s/%s" % [event, ch, num]
	if not midiCmds.has(key):
		midiCmds[key] = []
	midiCmds[key].append(
		{"addr":cmd, "actor":actor.name, "value":[minVal, maxVal]}
		)
#	print(midiCmds)
	print("added midi cmd %s: %s" % [key, midiCmds[key]])

func removeMidiCmd( event, ch, num, cmd, actor ):
	if String(num) == "*":
		for i in range(128):
			removeMidiCmd(event, ch, i, cmd, actor)
		return
	
	var key = "%s/ch%s/%s" % [event, ch, num]
	
	if not midiCmds.has(key): 
		print("trying to erase non-existing MIDI cmd: %s" % [key])
		return
	
	for cmd in midiCmds[key]:
		if cmd["actor"] == actor["name"]:
			midiCmds[key].erase(cmd)
			print("removed midi cmd %s: %s" % [key, cmd])
		else:
			print("trying to erease non-existing MIDI cmd: %s - %s" % [key, cmd])
	
	print(len(midiCmds[key]))
	if len(midiCmds[key]) == 0:
		midiCmds.erase(key)
	print(midiCmds)

func processMidiCmd( event, ch, num, val ):
	var key = getKey(event, ch, num)
	if not midiCmds.has(key):
		return
	
	for cmd in midiCmds[key]:
		eventToOsc(cmd, val)
#	
	if debug:
		print("key: %s cmd: %s" % [key, midiCmds[key]] )
#	print(midiCmds.keys())

func eventToOsc(cmd, value):
	print("event to osc: ", cmd, value)
	if not get_parent():
		return
	
	var main = get_parent()
	var addr = cmd["addr"]
	if not addr.begins_with("/"):
		addr = "/" + addr
	var actor = cmd["actor"]
	var minval = cmd["value"][0]
	var maxval = cmd["value"][1]
	if actor == null:
		main.evalCommandList([[addr]], null)
		return
	elif minval == null or maxval == null:
		main.evalCommandList([[addr, actor]], null)
		return
	var scaledValue  = Helper.linlin(value, 0, 127, minval, maxval)
	print("MIDI PARSE: original:%s scaled:%s" % [value, scaledValue])
	print("sending msg from MIDI: %s %s %f" % [addr, actor, value])
	main.evalCommandList([[addr, actor, scaledValue]], null)

func getKey(event, ch, num):
	return "%s/ch%s/%s" % [event, ch, num]

func listCmds():
	print(midiCmds)
	return midiCmds
