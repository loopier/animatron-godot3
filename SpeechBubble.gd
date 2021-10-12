extends Node2D

onready var textNode = $Anchor/RichTextLabel
onready var textBg = $Anchor/ColorRect
onready var padding = 16
onready var fadetime = 4

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	setText("ALO Blah\nBLAH alO")

func setText(text, wait = 3):
	visible = true
	$Timer.wait_time = wait
	$Timer.stop()
	textNode.bbcode_text = text
	resizeBubble()
	
#	$Tween.remove_all()
#	$Tween.interpolate_property(textNode, "modulate", Color(0,0,0,1), Color(0,0,0,0), fadetime, Tween.TRANS_EXPO)
#	$Tween.interpolate_property(textBg, "modulate", textBg.color, Color(0,0,0,0), fadetime)
#	$Tween.start()

func resizeBubble():
	var textSize = textNode.get_font("normal_font").get_string_size(textNode.text)
	textNode.margin_right = textSize.x
	textNode.margin_left = padding / 2
	textNode.margin_bottom = textSize.y * textNode.get_line_count() + padding
	textBg.margin_right = textSize.x / textNode.get_line_count() + padding
	textBg.margin_bottom = textSize.y * textNode.get_line_count() + padding

func _on_Timer_timeout():
	visible = false
