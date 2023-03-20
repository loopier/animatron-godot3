extends TextEdit

var regex
var main


func _ready():
	regex = RegEx.new()
	main = get_parent()
	var help = "================================================================\n" \
	+ "Type OSC messages with the format:\n" \
	+ "\n" \
	+ "/<CMD> <TARGET_NAME> [ARG_1 ... ARG_N]\n" \
	+ "\n" \
	+ "Shortcuts:\n" \
	+ "\t CTRL + ENTER - evaluate current line selection.\n" \
	+ "\t CTRL + E - toggle editor and post window.\n" \
	+ "\t CTRL + SHIFT + E - toggle editor.\n" \
	+ "\t CTRL + P - toggle post window.\n" \
	+ "\t CTRL + SHIFT + P - clear post window.\n" \
	+ "\n" \
	+ "For a full list of available OSC messages see the OSC\n" \
	+ "interface documentation in 'docs/Reference.md.html\n" \
	+ "================================================================\n\n"
	var defaultText = "/list/assets" 
	set_text(defaultText)
	main.get_node("PostTextEdit").set_text(help)
	print(main)


func _on_OscTextEdit_gui_input(event):
#	print(event)
#	accept_event()
	if event.is_action_pressed("eval_block", true):
		undo() # FIX: this is a hack to remove the inserted line on pressing ENTER
#		selectBlock()
		if get_selection_from_column() != get_selection_to_line():
			evalRegion()
		else:
			evalLine()

func evalRegion():
	print("eval region")
	textToOsc(get_selection_text())

func selectBlock():
	print("select block")

func evalLine():
	print("eval line")
	textToOsc(get_line(cursor_get_line()))

func textToOsc( msgString ):
	var cmds = []
	var lines = msgString.split("\n")
	for line in lines:
		var cmd = Array(line.split(" ")) # conver PoolStringArray to Array
		var addr = cmd[0].strip_edges()
		var args = cmd.slice(1,-1)
		main.evalOscCommand(addr, args, null)
#	sendMessage(cmds)
