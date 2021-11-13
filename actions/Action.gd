class_name Action
extends Node

onready var actor = get_parent()
var curTime : float = 0.0

func _init():
	pass
	

func _update_time(delta : float):
	curTime += delta

