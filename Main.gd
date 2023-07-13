extends Node2D

var osc: OscReceiver

func _ready():
	osc = OscReceiver.new()
	self.add_child(osc)
	osc.startServer()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
