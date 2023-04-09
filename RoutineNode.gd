extends Timer

var cmd : Array
onready var main = get_parent().get_parent()
onready var repeats = 0 setget setRepeats
onready var iteration = 0

func _ready():
	wait_time = 1.0
	connect("timeout", self, "next")

func setRepeats( inRepeats ):
	if inRepeats == "inf":
		repeats = 0
		return
	repeats = int(inRepeats)

func next():
	if len(cmd) <= 0:
		print("routine without commands: %s %s" % [name, cmd])
		return
	
	print("routine:%s iteration:%s/%s cmd:%s" % [name, iteration+1, repeats, cmd])
	main.evalCommandList([cmd], null)
	
	if repeats != 0 and iteration >= (repeats - 1):
			print("routine ended after %s times: %s" % [iteration + 1, name])
			iteration = 0
			remove_and_skip()
			return
	
	iteration = (iteration + 1) % max(repeats, 1)
