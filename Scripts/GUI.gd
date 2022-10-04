extends Control

class_name GUI

signal key_popup(key, player, show)
signal inv_closed
signal update_visual

var KeyPopup = preload("res://Scenes/KeyPopup.tscn")
var _key_popup = null
var holding_item = null
var initial_slot = null


# Called when the node enters the scene tree for the first time.
func _ready():
	_key_popup = KeyPopup.instance()
	_key_popup.visible = false
	add_child(_key_popup)
	self.connect("update_visual", self, "update_stat_visual")

	update_stat_visual()


func _on_Control_key_popup(key:String, player:Vector2, show:bool):
#	if !$Inventory.visible:
		if show:
			_key_popup.visible = true
			_key_popup.get_child(0).text = key
			_key_popup.set_position(Vector2(player.x + 8, player.y + 8))
		else:
			_key_popup.visible = false
		pass # Replace with function body.



func _input(event):
	if event.is_action_pressed("inventory"):
		
		$Inventory.visible = !$Inventory.visible
		$Inventory.initialize_inventory()
		$InventoryOpen.play()
		if $Inventory.visible == false:
			emit_signal("inv_closed")
		if _key_popup.visible == true:
			_key_popup.visible = false
	
	if event.is_action_pressed("ui_cancel"):
		if $Inventory.visible == true:
			$Inventory.visible = !$Inventory.visible
			$InventoryOpen.play()
			emit_signal("inv_closed")
		else:
			if $EscapeMenu.visible == false:
				$EscapeMenu.visible = true
			else:
				$EscapeMenu.visible = false
	
	
	#temporär für Karten
	if event.is_action_pressed("test"):
		var instance = load("res://Scenes/CardSelection.tscn").instance()
		self.add_child(instance)

func update_stat_visual():
	print("updated")
	get_node("Stats/Container/AttackDamage").text = str(PlayerInventory.stats["Attack"])
	get_node("Stats/Container2/Speed").text = str(PlayerInventory.stats["Speed"])
	get_node("Stats/Container3/AttackSpeed").text = str(PlayerInventory.stats["AttackSpeed"])
	
	get_parent().get_parent().get_node("Player").update_speed(PlayerInventory.stats["Speed"])
