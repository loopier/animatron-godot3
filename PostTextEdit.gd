extends TextEdit

var main

var shortcutsHelp = "\n\nKeyboard shortcuts:\n" \
	+ "\t CTRL + H - show this Help and OSC commands.\n" \
	+ "\t CTRL + ENTER - evaluate block.\n" \
	+ "\t SHIFT + ENTER - evaluate line.\n" \
	+ "\t CTRL + E - toggle editor and post window.\n" \
	+ "\t CTRL + SHIFT + E - toggle editor.\n" \
	+ "\t CTRL + P - toggle post window.\n" \
	+ "\t CTRL + SHIFT + P - clear post window.\n" \
	+ "\t CTRL + O - open a file in the text editor.\n" \
	+ "\t CTRL + S - save text editor contents to a file.\n" \
	+ "\t CTRL + D - duplicate line.\n" 

var help = "================================================================\n" \
	+ "To see the tutorial type:\n" \
	+ "\n" \
	+ "/tutorial\n" \
	+ "\n" \
	+ "and hit CTRL + ENTER while the cursor is on that line" \
	+ "\n" \
	+ shortcutsHelp \
	+ "\n" \
	+ "For a full list of available OSC messages see the OSC\n" \
	+ "interface documentation in 'docs/Reference.md.html\n" \
	+ "================================================================\n\n"

# Called when the node enters the scene tree for the first time.
func _ready():
	main = get_parent()
	set_text(help)

func _on_PostTextEdit_gui_input(event):
	if event.is_action_pressed("increase_editor_font", true):
		increaseFont()
	elif event.is_action_pressed("decrease_editor_font", true):
		decreaseFont()

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

func increaseFont():
	var font = get("custom_fonts/font")
	font.set_size(font.get_size() + 1)
	main.post("font size: %d" % [font.get_size()])
	
func decreaseFont():
	var font = get("custom_fonts/font")
	font.set_size(font.get_size() - 1)
	main.post("font size: %d" % [font.get_size()])

func setFontSize( size ):
	get("custom_fonts/font").set_size(size)
