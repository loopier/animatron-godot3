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
		evalBlock()
	elif event.is_action_pressed("open_file", true):
		main.get_node("OpenFileDialog").popup()
	elif event.is_action_pressed("save_file", true):
		main.get_node("SaveFileDialog").popup()
	elif event.is_action_pressed("duplicate_line", true):
		duplicateLine()

func evalRegion():
	print("eval region")
	textToOsc(get_selection_text())

func findPrevLinebreak( fromLine ):
	var ln = fromLine
	while ln > 0:
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
		ln = ln + 1
		if get_line(ln) == "":
			ln = ln - 1
			break
	return ln

func evalBlock():
	var line = cursor_get_line()
	var from = findPrevLinebreak(line) - 1
	var to = findNextLinebreak(line)
	cursor_set_column(len(get_line(line)))
	select(from, 0, to + 1, cursor_get_column())
	var text = get_selection_text()
	# group tabs with first non-indented line
	# FIX: 'defs' are already parsed in file, but doesn't work with this
	text = text.replace("\n\t", " ")
	textToOsc(text)
	deselect()

func evalLine():
	var ln = cursor_get_line()
	var col = cursor_get_column()
	selectLine()
	textToOsc(get_selection_text())
	deselect()
	cursor_set_line(ln)
	cursor_set_column(col)

func textToOsc( msgString ):
	var cmds = []
	var lines = msgString.split("\n")
	for line in lines:
		var cmd = Array(line.split(" ")) # convert PoolStringArray to Array
		var addr = cmd[0].strip_edges()
		var args = cmd.slice(1,-1)
		if len(addr) > 0:
			cmds.append(cmd)
	main.evalCommandList(cmds, null)

func selectLine():
	print("eval line")
	var line = cursor_get_line()
	cursor_set_column(len(get_line(line)))
	select(line, 0, line, cursor_get_column())

func duplicateLine():
	var col = cursor_get_column()
	cut()
	paste()
	paste()
	cursor_set_line(cursor_get_line() - 1)
	cursor_set_column(col)

