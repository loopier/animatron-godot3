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
			# use note number as velocity value, so we pass
			# the same value for both min and max. If they are null
			# we give them a midi number
			if minVal == null: minVal = i + 1
			if maxVal == null: maxVal = i + 1
			var newMinVal = Helper.linlin(i, 0,127, minVal, maxVal)
			var newMaxVal = newMinVal
			addMidiCmd(event, ch, i, cmd, actor, newMinVal, newMaxVal)
		return
	var key = "%s/ch%s/%s" % [event, ch, num]	
	midiCmds[key] = {"addr":cmd, "actor":actor.name, "value":[minVal, maxVal]}
#	print(midiCmds)
	Logger.info("added midi cmd %s: %s" % [key, midiCmds[key]])

func removeMidiCmd( event, ch, num, cmd, actor ):
	if String(num) == "*":
		for i in range(128):
			removeMidiCmd(event, ch, i, cmd, actor)
		return
	
	var key = "%s/ch%s/%s" % [event, ch, num]
	
	if not midiCmds.has(key): 
		Logger.info("trying to erase non-existing MIDI cmd: %s" % [key])
		return
	
	midiCmds.erase(key)
	Logger.info("midi cmds: %s" % [midiCmds])

func processMidiCmd( event, ch, num, val ):
	var key = getKey(event, ch, num)
	if not midiCmds.has(key):
		return
	
	eventToOsc(midiCmds[key], val)
#	
	if debug:
		Logger.debug("key: %s cmd: %s" % [key, midiCmds[key]] )
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
	var args  
	print("%s(%s) %s(%s)" % [minval, typeof(minval), maxval, typeof(maxval)])
	if minval is String and minval.is_valid_float() and maxval is String and maxval.is_valid_float():
		args = Helper.linlin(value, 0, 127, float(minval), float(maxval))
	elif (minval is float or minval is int) and (maxval is float or maxval is int):
		args = Helper.linlin(value, 0, 127, float(minval), float(maxval))
	else:
		args = minval
	
	Logger.verbose("MIDI PARSE: original:%s scaled:%s" % [value, args])
	Logger.verbose("sending msg from MIDI: %s %s %f" % [addr, actor, value])
	main.evalCommandList([[addr, actor, args]], null)

func getKey(event, ch, num):
	return "%s/ch%s/%s" % [event, ch, num]

func listCmds():
	var cmds : String
	for key in midiCmds:
		var cmd = midiCmds[key]["addr"]
		var actor = midiCmds[key]["actor"]
		var args = midiCmds[key]["value"]
		cmds = "%s\n%s: %s %s %s" % [cmds, key, cmd, actor, args]
#		print(cmd, midiCmds[cmd])
#	Logger.info(cmds)
	return cmds
