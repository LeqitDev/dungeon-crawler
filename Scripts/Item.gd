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
		change_item_name(item_name, category)
		get_node("ItemInfo/ItemType").text = str(category)
		change_category_color(category)
		get_node("ItemInfo/DamageAmount").text = str(attack)
		get_node("ItemInfo/DescriptionType").text = str(description)
		
	else:
		$ItemInfo.visible = false

func get_item_name():
	return item_name;
		
func change_item_name(itemname, this_categorie):
	get_node("ItemInfo/ItemName").text = str(itemname)
	
	if this_categorie == "Weapon":
		if itemname.ends_with("IV"):
			var length = (itemname.length()-2)
			itemname.erase(length, 2)
			itemname = itemname + " IV"
			get_node("ItemInfo/ItemName").text = str(itemname)
			get_node("ItemInfo/ItemName").set("custom_colors/font_color", Color(1,0,0))
			$spotlight.modulate = Color(1,0,0)
		elif itemname.ends_with("V"):
			var length = (itemname.length()-1)
			itemname.erase(length, 1)
			itemname = itemname + " V"
			get_node("ItemInfo/ItemName").text = str(itemname)
			get_node("ItemInfo/ItemName").set("custom_colors/font_color", Color(1,1,0))
			$spotlight.modulate = Color(1,1,0)
		elif itemname.ends_with("III"):
			var length = (itemname.length()-3)
			itemname.erase(length, 3)
			itemname = itemname + " III"
			get_node("ItemInfo/ItemName").text = str(itemname)
			get_node("ItemInfo/ItemName").set("custom_colors/font_color", Color(0,0,1))
			$spotlight.modulate = Color(0,0,1)
		elif itemname.ends_with("II"):
			var length = (itemname.length()-2)
			itemname.erase(length, 2)
			itemname = itemname + " II"
			get_node("ItemInfo/ItemName").text = str(itemname)
			get_node("ItemInfo/ItemName").set("custom_colors/font_color", Color(0,1,0))
			$spotlight.modulate = Color(0,1,0)


func change_category_color(this_category):
	var red = {
		0: "Weapon"
	}
	
	var green = {
		0: "Consumable"
	}
	
	var yellow = {
		0: "Coin"
	}
	
	for i in red:
		if this_category == red[i]:
			get_node("ItemInfo/ItemType").set("custom_colors/font_color", Color(1,0,0))
	
	for i in green:
		if this_category == green[i]:
			get_node("ItemInfo/ItemType").set("custom_colors/font_color", Color(0,1,0))
	
	for i in yellow:
		if this_category == yellow[i]:
			get_node("ItemInfo/ItemType").set("custom_colors/font_color", Color(1,1,0))
