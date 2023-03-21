extends TextEdit

var regex
var main

func _ready():
	regex = RegEx.new()
	main = get_parent()
	var defaultText = "/list/assets" 
	set_text(defaultText)
	set_visible(true)


func _on_OscTextEdit_gui_input(event):
#	print(event)
#	accept_event()
	if event.is_action_pressed("eval_line", true):
		undo() # FIX: this is a hack to remove the inserted line on pressing ENTER
		evalLine()
	elif event.is_action_pressed("eval_block", true):
		undo() # FIX: this is a hack to remove the inserted line on pressing ENTER
		selectBlock()

func evalRegion():
	print("eval region")
	textToOsc(get_selection_text())

func findPrevLinebreak( fromLine ):
	var ln = fromLine
	while ln > 0:
		print("p ln:",ln)
		ln = ln - 1
		if get_line(ln) == "":
			ln = ln + 1
			break
	return ln

func findNextLinebreak( fromLine ):
	if get_line(fromLine) == "":
		return fromLine
	var ln = fromLine
	while ln < get_line_count():
		print("n ln:",ln)
		ln = ln + 1
		if get_line(ln) == "":
			ln = ln - 1
			break
	return ln

func selectBlock():
	print("select block")
	var line = cursor_get_line()
	var from = findPrevLinebreak(line) - 1
	var to = findNextLinebreak(line)
	cursor_set_column(len(get_line(line)))
	select(from, 0, to + 1, cursor_get_column())
	textToOsc(get_selection_text())
	deselect()


func evalLine():
	print("eval line")
	var line = cursor_get_line()
	cursor_set_column(len(get_line(line)))
	select(line, 0, line, cursor_get_column())
#	textToOsc(get_selection_text())
#	deselect()

func textToOsc( msgString ):
	var cmds = []
	var lines = msgString.split("\n")
	for line in lines:
		var cmd = Array(line.split(" ")) # conver PoolStringArray to Array
		var addr = cmd[0].strip_edges()
		var args = cmd.slice(1,-1)
		main.evalOscCommand(addr, args, null)
#	sendMessage(cmds)
