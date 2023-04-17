extends Node

enum {
	LOG_LEVEL_FATAL,
	LOG_LEVEL_ERROR,
	LOG_LEVEL_WARNING,
	LOG_LEVEL_INFO,
	LOG_LEVEL_DEBUG,
	LOG_LEVEL_VERBOSE,
} 

const levelNames = ["FATAL", "ERROR", "WARNING", "INFO", "DEBUG", "VERBOSE"]

onready var level = LOG_LEVEL_INFO setget setLevel, getLevel
var target : TextEdit


func setTarget( inTarget ):
	target = inTarget

func setLevel( inLevel ):
	level = inLevel
	logMsg("Log level set to: %s" % [levelNames[level]])

func getLevel():
	return level

func setLevelFatal():
	setLevel(LOG_LEVEL_FATAL)

func setLevelError():
	setLevel(LOG_LEVEL_ERROR)

func setLevelWarning():
	setLevel(LOG_LEVEL_WARNING)

func setLevelInfo():
	setLevel(LOG_LEVEL_INFO)

func setLevelDebug():
	setLevel(LOG_LEVEL_DEBUG)

func setLevelVerbose():
	setLevel(LOG_LEVEL_VERBOSE)

func fatal( msg ):
	logMsg("[FATAL]: %s" % [msg], true)

func error( msg ):
	if level < LOG_LEVEL_ERROR:
		return
	logMsg("[ERROR]: %s" % [msg], true)

func warn( msg ):
	if level < LOG_LEVEL_WARNING:
		return
	logMsg("[WARNING]: %s" % [msg], true)

func info( msg ):
	if level < LOG_LEVEL_INFO:
		return
	logMsg("[INFO]: %s" % [msg], true)

func debug( msg ):
	if level < LOG_LEVEL_DEBUG:
		return
	logMsg("[DEBUG]: %s" % [msg])

func verbose( msg ):
	if level < LOG_LEVEL_VERBOSE:
		return
	logMsg("[VERBOSE]: %s" % [msg])

func logMsg( msg, post=false ):
	print(msg)
	if target != null and post:
		target.append(msg)
