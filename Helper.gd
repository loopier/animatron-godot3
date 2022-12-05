extends Object
class_name Helper


############################################################
# Global (static) helper functions
############################################################

static func getGlobalPath(projectPath : String) -> String:
	var path = ""
	if OS.has_feature("editor"):
		# Running from an editor binary.
		# `path` will contain the absolute path to `hello.txt` located in the project root.
		if not projectPath.is_abs_path():
			projectPath = "res://".plus_file(projectPath)
		path = ProjectSettings.globalize_path(projectPath)
	else:
		# Running from an exported project.
		# `path` will contain the absolute path to `hello.txt` next to the executable.
		# This is *not* identical to using `ProjectSettings.globalize_path()` with a `res://` path,
		# but is close enough in spirit.
		if projectPath.begins_with("res://"):
			projectPath = projectPath.substr("res://".length())
		path = (
				OS.get_executable_path().get_base_dir().plus_file(projectPath)
				if projectPath.is_rel_path()
				else projectPath
		)
	return path


# Return a path relative to a default directory, if you provide
# a simple filename without any other path elements
# 	getPathWithDefaultDir("hello.txt", "test") -> "test/hello.txt"
# 	getPathWithDefaultDir("another/hello.txt", "test") -> "another/hello.txt"
static func getPathWithDefaultDir(path : String, defaultDir : String) -> String:
	if path.get_file() == path:
		path = defaultDir.plus_file(path)
	return getGlobalPath(path)


# Get a bool argument
static func getBool(arg) -> bool:
	if typeof(arg) == TYPE_STRING:
		return arg.to_lower() == "true" or bool(int(arg))
	else:
		return bool(arg)


# Get a Vector2 argument from a single float/int value,
# an array, or a string of two floats separated by a comma
static func getVector2(arg) -> Vector2:
	var value : Vector2
	if typeof(arg) == TYPE_STRING:
		var parts = arg.split_floats(',')
		if not parts.empty():
			value = Vector2(parts[0], parts[0])
		if parts.size() > 1:
			value.y = parts[1]
	elif typeof(arg) == TYPE_ARRAY:
		if not arg.empty():
			value = Vector2(arg[0], arg[0])
		if arg.size() > 1:
			value.y = arg[1] as float
	else:
		value = Vector2(float(arg), float(arg))
	return value
	
static func linlin(val, inmin, inmax, outmin, outmax):
	return (float(val - inmin) / float(inmax - inmin)) * float(outmax - outmin) + outmin
