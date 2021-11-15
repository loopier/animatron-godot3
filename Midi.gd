class_name Midi
extends Node





# Called when the node enters the scene tree for the first time.
func _ready():
	OS.open_midi_inputs()
	print("MIDI devices: ",OS.get_connected_midi_inputs())
	set_process_unhandled_input(true)

func _unhandled_input(event):
	if(event is InputEventMIDI):
#		print("MIDI: ", event.as_text())
		var msg =  "ch:" + str(event.get_channel()) + " note:" + str(event.get_pitch()) + " vel:" + str(event.get_velocity()) + " inst:" + str(event.get_instrument()) + " pres:" + str(event.get_pressure()) + " cc#:" + str(event.get_controller_number()) + " ccv:" + str(event.get_controller_value())
		print(msg)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
