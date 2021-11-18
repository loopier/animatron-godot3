extends Node
class_name CustomCommands

var commands = {}


func defineCommand(defCommand : String, defArgs : Array, commandList : Array):
	commands[defCommand] = { args = defArgs, cmds = commandList }


func loadCommandFile(path):
	var file = File.new()
	file.open(path, File.READ)
	if not file.is_open():
		print("Unable to open command defs file: " + path)
		return false
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
			if filteredLine[0][0] == '#':
				# Ignore comment lines that start with '#'
				continue
			if filteredLine[0] == "def" && filteredLine.size() > 1:
				if defCommand && !commandList.empty():
					defineCommand(defCommand, defArgs, commandList)
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
		defineCommand(defCommand, defArgs, commandList)

	for k in commands:
		print("Command: ", k, "\n", commands[k])
	return true


func hasCommand(address):
	return commands.has(address)


func getCommand(address):
	return commands[address]

func getCommands():
	return commands
