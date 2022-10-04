extends Node


var rng = RandomNumberGenerator.new()


var cardTexts = {
	0: ["Overall attack Damage: [color=red]1.25x[/color]","Attack", 1.25],
	1: ["Overall attack Speed: [color=blue]1.25x[/color]","AttackSpeed", 1.25],
	2: ["Overall movement Speed: [color=blue]220[/color]","Speed", 220], #--> slot_index: [text, effect, value]
}

var back_tex = preload("res://Assets/cards/Card-back.png")
var front_tex = preload("res://Assets/cards/Card-front.png")

var back_style: StyleBoxTexture = null
var front_style: StyleBoxTexture = null

# Called when the node enters the scene tree for the first time.
func _ready():
	back_style = StyleBoxTexture.new()
	front_style = StyleBoxTexture.new()
	back_style.texture = back_tex
	front_style.texture = front_tex


func open():
	rng.randomize()
	var length = cardTexts.size()
	var random = rng.randi()%(length)
	
	$".".texture = front_tex
	$RichTextLabel.bbcode_text = cardTexts[random][0]
	PlayerInventory.set_stat(cardTexts[random][1], cardTexts[random][2])
	print("Stat " + str(cardTexts[random][1]) + " updated to: " + str(cardTexts[random][2]))
	get_tree().root.get_node("/root/MainGame/Control/Control").emit_signal("update_visual")
	$RichTextLabel.visible = true
