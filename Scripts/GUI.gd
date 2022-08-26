extends Control

class_name GUI

signal key_popup(key, player, show)

var KeyPopup = preload("res://Scenes/KeyPopup.tscn")
var _key_popup:TextureRect = null




# Called when the node enters the scene tree for the first time.
func _ready():
	_key_popup = KeyPopup.instance()
	_key_popup.visible = false
	add_child(_key_popup)
	pass # Replace with function body.




func _on_Control_key_popup(key:String, player:Vector2, show:bool):
	if !$Inventory.visible:
		if show:
			_key_popup.visible = true
			_key_popup.get_child(0).text = key
			_key_popup.set_position(Vector2(player.x + 20, player.y - 20))
		else:
			_key_popup.visible = false
		pass # Replace with function body.



func _input(event):
	if event.is_action_pressed("inventory"):
		$Inventory.visible = !$Inventory.visible
		$InventoryOpen.play()
		
		if _key_popup.visible == true:
			_key_popup.visible = false
