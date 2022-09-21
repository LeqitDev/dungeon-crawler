extends Node2D


var item_name
var item_quantity

func set_item(nm, qt):
	item_name = nm
	item_quantity = qt
	$TextureRect.texture = PlayerInventory.textures[item_name]
	
	var stack_size = int(JsonData.item_data[item_name]["StackSize"])
	if stack_size == 1:
		$Label.visible = false
	else:
		$Label.visible = true
		$Label.text = String(item_quantity)

func add_item_quantity(amount_to_add):
	item_quantity += amount_to_add
	$Label.text = String(item_quantity)
	
func decrease_item_quantity(amount_to_remove):
	item_quantity -= amount_to_remove
	$Label.text = String(item_quantity)

func toggle_item_info(iteminfo, itemname):
	if iteminfo:
		
		var stack_size = int(JsonData.item_data[itemname]["StackSize"])
		var description = JsonData.item_data[itemname]["Description"]
		var category = JsonData.item_data[itemname]["ItemCategory"]
		var attack = 0
		
		if category != "Consumable":
			attack = int(JsonData.item_data[itemname]["ItemDamage"])
		else:
			attack = 0
		
		$ItemInfo.visible = true
		get_node("ItemInfo/ItemName").text = str(item_name)
		get_node("ItemInfo/ItemType").text = str(category)
		get_node("ItemInfo/DamageAmount").text = str(attack)
		get_node("ItemInfo/DescriptionType").text = str(description)
		
	else:
		$ItemInfo.visible = false
