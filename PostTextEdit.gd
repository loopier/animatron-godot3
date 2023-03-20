extends TextEdit
var shortcutsHelp = "\t CTRL + ENTER - evaluate current line selection.\n" \
	+ "\t CTRL + E - toggle editor and post window.\n" \
	+ "\t CTRL + SHIFT + E - toggle editor.\n" \
	+ "\t CTRL + P - toggle post window.\n" \
	+ "\t CTRL + SHIFT + P - clear post window.\n" 

var help = "================================================================\n" \
	+ "Type OSC messages with the format:\n" \
	+ "\n" \
	+ "/<CMD> <TARGET_NAME> [ARG_1 ... ARG_N]\n" \
	+ "\n" \
	+ "Shortcuts:\n" \
	+ shortcutsHelp \
	+ "\n" \
	+ "For a full list of available OSC messages see the OSC\n" \
	+ "interface documentation in 'docs/Reference.md.html\n" \
	+ "================================================================\n\n"

# Called when the node enters the scene tree for the first time.
func _ready():
	set_text(help)

func append( msg ):
	set_text("%s\n%s" % [get_text(), msg])
	scroll_vertical = INF

func printDict( dict ):
	for key in dict.keys():
		append("%s: %s" % [key, dict[key]])

func clear():
	set_text("")

func help():
	append(shortcutsHelp)