extends KinematicBody2D


var player = null
var is_opened = false
var posbody = null

var textures = {
	"Chest": preload("res://Assets/chests/Chest.png"),
	"Chest_empty": preload("res://Assets/chests/Chest_empty.png"),
}

# Called when the node enters the scene tree for the first time.
func _ready():
	is_opened = false


func pick_up_item(body, theposbody):
	player = body
	posbody = theposbody
	if !is_opened:
		$Sprite.texture =  textures["Chest_empty"]
		$openSound.play()
		get_parent().get_node("Room").emit_signal("drop_item", "chest", 1, Vector2(posbody.position.x , posbody.position.y - 20))
		is_opened = true
