extends TextEdit


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func append( msg ):
	set_text("%s\n%s" % [get_text(), msg])
	scroll_vertical = INF

func printDict( dict ):
	for key in dict.keys():
		append("%s: %s" % [key, dict[key]])

func clear():
	set_text("")
