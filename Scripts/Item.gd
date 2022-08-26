extends Node2D


var item_name
var item_quantity
var textures = {
	"Sword": preload("res://Assets/gui/item_icons/sword.png"),
	"Arrow": preload("res://Assets/gui/item_icons/arrow.png"),
}

# Called when the node enters the scene tree for the first time.
func _ready():
	var rand_val = randi() % 2
	if rand_val == 0:
		item_name = "Sword"
	else:
		item_name = "Arrow"
	
	$TextureRect.texture = textures[item_name]
	var stack_size = int(JsonData.item_data[item_name]["StackSize"])
	item_quantity = randi() % stack_size + 1
	
	
	if stack_size == 1:
		$Label.visible = false
	else:
		$Label.text = String(item_quantity)

func add_item_quantity(amount_to_add):
	item_quantity += amount_to_add
	$Label.text = String(item_quantity)
	
func decrease_item_quantity(amount_to_remove):
	item_quantity -= amount_to_remove
	$Label.text = String(item_quantity)
