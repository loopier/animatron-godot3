extends Node2D

onready var textNode = $Anchor/RichTextLabel
onready var textBg = $Anchor/ColorRect
onready var padding = 16
onready var fadetime = 0
onready var offset = Vector2(0, -96)

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
#	setText("ALO Blah\nBLAH alO")

func setText(text, wait = 3):
	visible = true
	$Timer.wait_time = wait
	$Timer.stop()
	text = "[center]" + text
	textNode.bbcode_text = text
	resizeBubble()
	
	$Tween.remove_all()
	# $Tween.interpolate_property(textNode, "modulate", Color(0,0,0,1), Color(0,0,0,0), fadetime, Tween.TRANS_EXPO)
	# $Tween.interpolate_property(textBg, "modulate", textBg.color, Color(0,0,0,0), fadetime)
	$Tween.start()

# distribute text on even lines
func formatText():
	print("TODO: format text in even lines")
	print("TODO: multiline")
	var words = textNode.text.count(" ") + 1
	# print("words: ", words)

func resizeBubble():
	formatText()
	var textSize = textNode.get_font("normal_font").get_string_size(textNode.text)
	textNode.margin_right = textSize.x + padding
	textNode.margin_bottom = textSize.y * textNode.get_line_count() + padding


func _on_Timer_timeout():
	visible = false


func _on_Tween_tween_all_completed():
	$Timer.start()


func _on_RichTextLabel_resized():
	textBg.margin_right = textNode.margin_right
	textBg.margin_bottom = textNode.margin_bottom
	offset.x = textBg.margin_right / (-2)
	$Anchor.set_position(offset)
