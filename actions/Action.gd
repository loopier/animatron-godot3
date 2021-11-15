extends Node
class_name Action, "res://icons/action.svg"

onready var actor = get_parent()
onready var offsetNode = actor.get_node("Offset")
var curTime : float = 0.0

func _init():
	pass
	

func _update_time(delta : float):
	curTime += delta

