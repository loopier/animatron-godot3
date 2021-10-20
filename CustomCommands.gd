extends Node

var commands = {}

func _ready():
	pass

func loadCommandFile(path):
	var file = File.new()
	file.open(path, File.READ)
	var lineNum = 1
	var defCommand
	var defArgs = []
	var commandList = []
	while file.is_open() && !file.eof_reached():
		var filteredLine = []
		# @todo Replace when Godot Array gets a filter() function (4.0)
		for elem in file.get_csv_line(" "):
			if !elem.empty():
				filteredLine.append(elem.strip_edges())
		if !file.eof_reached() && !filteredLine.empty():
			if filteredLine[0] == "def" && filteredLine.size() > 1:
				if defCommand && !commandList.empty():
					commands[defCommand] = { args = defArgs, cmds = commandList }
				defCommand = filteredLine[1]
				defArgs = filteredLine.slice(2, -1)
				commandList = []
				print("%d: Defining '%s' with args: %s" % [lineNum, defCommand, defArgs])
			else:
				print("%d: [%s] %s" % [lineNum, defCommand, filteredLine])
				commandList.append(filteredLine)
		lineNum += 1
	file.close()
	if defCommand && !commandList.empty():
		commands[defCommand] = { args = defArgs, cmds = commandList }

	for k in commands:
		print("Command: ", k, "\n", commands[k])
