extends Node

const SlotClass = preload("res://Scripts/Slot.gd")
const ItemClass = preload("res://Scripts/Item.gd")
const NUM_INVENTORY_SLOTS = 11
const NUM_HOTBAR_SLOTS = 2

var textures = {
	"Sword": preload("res://Assets/gui/item_icons/sword/sword.png"),
	"SwordII": preload("res://Assets/gui/item_icons/sword/swordII.png"),
	"SwordIII": preload("res://Assets/gui/item_icons/sword/swordIII.png"),
	"SwordIV": preload("res://Assets/gui/item_icons/sword/swordIV.png"),
	"SwordV": preload("res://Assets/gui/item_icons/sword/swordV.png"),
	"Arrow": preload("res://Assets/gui/item_icons/arrow.png"),
	"Redberry": preload("res://Assets/gui/item_icons/redberry.png"),
	"Axe": preload("res://Assets/gui/item_icons/axe/axe.png"),
	"AxeII": preload("res://Assets/gui/item_icons/axe/axeII.png"),
	"AxeIII": preload("res://Assets/gui/item_icons/axe/axeIII.png"),
	"AxeIV": preload("res://Assets/gui/item_icons/axe/axeIV.png"),
	"AxeV": preload("res://Assets/gui/item_icons/axe/axeV.png"),
	"Coin": preload("res://Assets/gui/item_icons/coin.png"),
}

var inventory = {
	0: ["Arrow", 1], #--> slot_index: [item_name, item_quantity]
	1: ["Redberry", 5],
	2: ["Axe", 1],
	3: ["AxeII", 1],
	4: ["AxeIII", 1],
	5: ["AxeIV", 1],
	6: ["AxeV", 1],
	7: ["Coin", 1]
}

var hotbar = {
	0: ["Sword", 1],
	1: ["Arrow", 1]
}

var active_item_slot = 0

func add_item(item_name, item_quantity):
	for item in inventory:
		if inventory[item][0] == item_name:
			var stack_size = int(JsonData.item_data[item_name]["StackSize"])
			var able_to_add = stack_size - inventory[item][1]
			if able_to_add >= item_quantity:
				inventory[item][1] += item_quantity
				update_slot_visual(item, inventory[item][0], inventory[item][1])
				return
			else:
				inventory[item][1] += able_to_add
				update_slot_visual(item, inventory[item][0], inventory[item][1])
				item_quantity = item_quantity - able_to_add
	for i in range(NUM_INVENTORY_SLOTS):
		if inventory.has(i) == false:
			inventory[i] = [item_name, item_quantity]
			update_slot_visual(i, inventory[i][0], inventory[i][1])
			return

func update_slot_visual(slot_index, item_name, new_quantity):
	var slot = get_tree().root.get_node("/root/MainGame/Control/Control/Inventory/GridContainer/Slot" + str(slot_index + 1))
	if slot.item != null:
		slot.item.set_item(item_name, new_quantity)
	else:
		slot.initialize_item(item_name, new_quantity)
		
func add_item_to_empty_slot(item: ItemClass, slot: SlotClass, is_hotbar: bool = false):
	if is_hotbar:
		hotbar[slot.slot_index] = [item.item_name, item.item_quantity]
	else:
		inventory[slot.slot_index] = [item.item_name, item.item_quantity]

func remove_item(slot: SlotClass, is_hotbar: bool = false):
	if is_hotbar:
		hotbar.erase(slot.slot_index)
	else:
		inventory.erase(slot.slot_index)
	
func add_item_quantity(slot: SlotClass, quantity_to_add: int, is_hotbar: bool = false):
	if is_hotbar:
		hotbar[slot.slot_index][1] += quantity_to_add
	else:
		inventory[slot.slot_index][1] += quantity_to_add

func active_item_scroll_up():
	active_item_slot = (active_item_slot + 1) % NUM_HOTBAR_SLOTS
	
func active_item_scroll_down():
	if active_item_slot == 0:
		active_item_slot = NUM_HOTBAR_SLOTS - 1
	else: 
		active_item_slot -= 1
	
func get_active_item():
	return hotbar[active_item_slot][0]
