extends Control

const SlotClass = preload("res://Scripts/Slot.gd")
onready var hotbar = $HotbarContainer
onready var slots = hotbar.get_children()
var player_inv = PlayerInventory

signal active_item_updated

func _ready():
	for i in range(slots.size()):
		slots[i].connect("gui_input", self, "slot_gui_input", [slots[i]])
		PlayerInventory.connect("active_item_updated", slots[i], "refresh_style")
		
		slots[i].slot_index = i
		slots[i].slot_type = SlotClass.SlotType.HOTBAR
	initialize_hotbar()
		
func initialize_hotbar():
	for i in range(slots.size()):
		if PlayerInventory.hotbar.has(i):
			slots[i].initialize_item(PlayerInventory.hotbar[i][0], PlayerInventory.hotbar[i][1])


func slot_gui_input(event: InputEvent, slot: SlotClass):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT && event.pressed:
			if find_parent("Control").holding_item != null:
				if !slot.item: # Place holding item to slot
					left_click_empty_slot(slot)
				else: # Swap holding item with item in slot
					if find_parent("Control").holding_item.item_name != slot.item.item_name:
						left_click_different_item(event, slot)
					else: # selbes Item also zusammenführen
						left_click_same_item(slot)	
			elif slot.item:	
				left_click_not_holding(slot)
				find_parent("Control").initial_slot = slot

func left_click_empty_slot(slot: SlotClass):
	player_inv.add_item_to_empty_slot(find_parent("Control").holding_item, slot, true)
	slot.putIntoSlot(find_parent("Control").holding_item)
	find_parent("Control").holding_item = null
	player_inv.player.emit_signal("update_player_right_hand", player_inv.textures[slot.item.item_name])
	
func left_click_different_item(event: InputEvent, slot: SlotClass):
	player_inv.remove_item(slot)
	player_inv.add_item_to_empty_slot(find_parent("Control").holding_item, slot, true)
	var temp_item = slot.item
	slot.pickFromSlot()
	temp_item.global_position = Vector2(get_global_mouse_position().x -16, get_global_mouse_position().y -16)
	slot.putIntoSlot(find_parent("Control").holding_item)
	find_parent("Control").holding_item = temp_item
	player_inv.player.emit_signal("update_player_right_hand", player_inv.textures[slot.item.item_name])
	
func left_click_same_item(slot: SlotClass):
	var stack_size = int(JsonData.item_data[slot.item.item_name]["StackSize"])
	var able_to_add = stack_size - slot.item.item_quantity
	if able_to_add >= find_parent("Control").holding_item.item_quantity:
		player_inv.add_item_quantity(slot, find_parent("Control").holding_item.item_quantity, true)
		slot.item.add_item_quantity(find_parent("Control").holding_item.item_quantity)
		find_parent("Control").holding_item.queue_free()
		find_parent("Control").holding_item = null
	else:
		slot.item.add_item_quantity(able_to_add)
		find_parent("Control").holding_item.decrease_item_quantity(able_to_add)
		
func left_click_not_holding(slot: SlotClass):
	player_inv.remove_item(slot, true)
	find_parent("Control").holding_item = slot.item
	slot.pickFromSlot()
	find_parent("Control").holding_item.global_position = Vector2(get_global_mouse_position().x -16, get_global_mouse_position().y -16)
	
func close_inventory_holding_item(slot: SlotClass):
	if find_parent("Control").holding_item != null:
		player_inv.add_item_to_empty_slot(find_parent("Control").holding_item, slot, true)
		slot.putIntoSlot(find_parent("Control").holding_item)
		find_parent("Control").holding_item = null

func refresh_style(slot: SlotClass):
	slot.refresh_style()
