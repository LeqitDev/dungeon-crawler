extends Control

const SlotClass = preload("res://Scripts/Slot.gd")
onready var inventory_slots = $GridContainer
var inv_open = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var slots = inventory_slots.get_children()
	for i in range(slots.size()):
		slots[i].connect("gui_input", self, "slot_gui_input", [slots[i]])
		slots[i].connect("mouse_entered", self, "slot_mouse_entered", [slots[i]])
		slots[i].connect("mouse_exited", self, "slot_mouse_exited", [slots[i]])
		slots[i].slot_index = i
		slots[i].slot_type = SlotClass.SlotType.INVENTORY
	initialize_inventory()
		
func initialize_inventory():
	var slots = inventory_slots.get_children()
	for i in range(slots.size()):
		if PlayerInventory.inventory.has(i):
			slots[i].initialize_item(PlayerInventory.inventory[i][0], PlayerInventory.inventory[i][1])


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
				
	
func _input(event):
	if find_parent("Control").holding_item:
		find_parent("Control").holding_item.global_position = Vector2(get_global_mouse_position().x -16, get_global_mouse_position().y -16)
		if event.is_action_pressed("inventory"):
			close_inventory_holding_item(find_parent("Control").initial_slot)

func left_click_empty_slot(slot: SlotClass):
	PlayerInventory.add_item_to_empty_slot(find_parent("Control").holding_item, slot)
	slot.putIntoSlot(find_parent("Control").holding_item)
	find_parent("Control").holding_item = null
	
func left_click_different_item(event: InputEvent, slot: SlotClass):
	PlayerInventory.remove_item(slot)
	PlayerInventory.add_item_to_empty_slot(find_parent("Control").holding_item, slot)
	var temp_item = slot.item
	slot.pickFromSlot()
	temp_item.global_position = Vector2(get_global_mouse_position().x -16, get_global_mouse_position().y -16)
	slot.putIntoSlot(find_parent("Control").holding_item)
	find_parent("Control").holding_item = temp_item
	
func left_click_same_item(slot: SlotClass):
	var stack_size = int(JsonData.item_data[slot.item.item_name]["StackSize"])
	var able_to_add = stack_size - slot.item.item_quantity
	if able_to_add >= find_parent("Control").holding_item.item_quantity:
		PlayerInventory.add_item_quantity(slot, find_parent("Control").holding_item.item_quantity)
		slot.item.add_item_quantity(find_parent("Control").holding_item.item_quantity)
		find_parent("Control").holding_item.queue_free()
		find_parent("Control").holding_item = null
	else:
		slot.item.add_item_quantity(able_to_add)
		find_parent("Control").holding_item.decrease_item_quantity(able_to_add)
		
func left_click_not_holding(slot: SlotClass):
	slot.item.toggle_item_info(false, slot.item.item_name)
	PlayerInventory.remove_item(slot)
	find_parent("Control").holding_item = slot.item
	slot.pickFromSlot()
	find_parent("Control").holding_item.global_position = Vector2(get_global_mouse_position().x -16, get_global_mouse_position().y -16)
	
func close_inventory_holding_item(slot: SlotClass):
	if find_parent("Control").holding_item != null:
		PlayerInventory.add_item_to_empty_slot(find_parent("Control").holding_item, slot)
		slot.putIntoSlot(find_parent("Control").holding_item)
		find_parent("Control").holding_item = null


func slot_mouse_entered(slot: SlotClass):
	if find_parent("Control").holding_item == null:
		if slot.item:
			slot.item.toggle_item_info(true, slot.item.item_name)
func slot_mouse_exited(slot: SlotClass):
	if find_parent("Control").holding_item == null:
		if slot.item:
			slot.item.toggle_item_info(false, slot.item.item_name)
