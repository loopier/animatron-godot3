# A class to manage typing with images
class_name Letters
extends Node


onready var main = get_parent()
var alphabet := { 
	"a": "letter-a",
	"b": "letter-b",
}


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func loadAlphabet():
	print("TODO: load alphabet")
	main.evalOscCommand("/load", ["letter-a"], null)
	main.evalOscCommand("/create", ["a", "letter-a"], null)



func setLetter(letter, source):
	alphabet[letter] = source
