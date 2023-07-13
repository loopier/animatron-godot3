extends Node2D

var osc: OscReceiver

func _ready():
	osc = OscReceiver.new()
	self.add_child(osc)
	osc.startServer()
	osc.osc_msg_received.connect(_on_osc_msg_received)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_osc_msg_received(addr, args, sender):
	print("OSC msg received in Main from '%s': %s %s" % [sender, addr, args])
