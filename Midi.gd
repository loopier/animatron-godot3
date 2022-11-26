class_name Midi
extends Node

signal note_on_received(num, velocity, ch)
signal note_off_received(num, velocity, ch)
signal cc_received(num, value, ch)

var debug = true

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
