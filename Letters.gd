# A class to manage typing with images
class_name Letters
extends Node


onready var main = get_parent()
# spacing is a multiplier of actor width
var spacing = 1
var scale = 1
var msg = ""
var alphabet := { 
	"a": "letter-a",
	"b": "letter-b",
	"c": "letter-c",
	"d": "letter-d",
	"e": "letter-e",
	"f": "letter-f",
	"g": "letter-g",
	"h": "letter-h",
	"i": "letter-i",
	"j": "letter-j",
	"k": "letter-k",
	"l": "letter-l",
	"m": "letter-m",
	"n": "letter-n",
	"o": "letter-o",
	"p": "letter-p",
	"q": "letter-q",
	"r": "letter-r",
	"s": "letter-s",
	"t": "letter-t",
	"u": "letter-u",
	"v": "letter-v",
	"w": "letter-w",
	"x": "letter-x",
	"y": "letter-y",
	"z": "letter-z",
}


# Called when the node enters the scene tree for the first time.
func _ready():
	# loadAlphabet()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func loadAlphabet(inArgs, sender=null):
	for letter in alphabet.keys():
		main.evalOscCommand("/load", [alphabet[letter]], null)


func setLetter(inArgs, sender=null):
	var letter = inArgs[0]
	var source = inArgs[1]
	alphabet[letter] = source


func write(inArgs, sender=null):
	msg = inArgs[0]
	for i in msg.length():
		var letter = msg[i]
		var pos = i * spacing
		print(letter + ": " + alphabet[letter])
		main.evalOscCommand("/create", [letter, alphabet[letter]], null)
		main.evalOscCommand("/position", [letter, pos, 0.5], null)


func setSpacing(inArgs, sender=null):
	spacing = inArgs[0] as float
	write([msg], null)


func setScale(inArgs, sender=null):
	print("TODO SCALE " + str(inArgs[0]))
	for x in msg:
		main.evalOscCommand("/scale", [x, inArgs[0]], null)
