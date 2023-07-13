extends Node2D

var osc: OscReceiver

func _ready():
	Log.setLevel(Log.LOG_LEVEL_VERBOSE)
	Log.verbose("alo")
	osc = OscReceiver.new()
	self.add_child(osc)
	osc.startServer()
	osc.osc_msg_received.connect(_on_osc_msg_received)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_osc_msg_received(addr, args, sender):
	# map incoming OSC message to a function
	Log.warn("TODO: Map incoming messages to functions: Main._on_osc_msg_received")
