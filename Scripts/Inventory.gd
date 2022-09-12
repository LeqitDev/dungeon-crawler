extends Control

const SlotClass = preload("res://Scripts/Slot.gd")
onready var inventory_slots = $GridContainer
var holding_item = null
var inv_open = false
var slot_wo_mans_her_hat = null
var player_inv = PlayerInventory

# Called when the node enters the scene tree for the first time.
func _ready():
	var slots = inventory_slots.get_children()
	for i in range(slots.size()):
		slots[i].connect("gui_input", self, "slot_gui_input", [slots[i]])
		slots[i].slot_index = i
	initialize_inventory()
		
func initialize_inventory():
	var slots = inventory_slots.get_children()
	for i in range(slots.size()):
		if player_inv.inventory.has(i):
			slots[i].initialize_item(player_inv.inventory[i][0], player_inv.inventory[i][1])


func slot_gui_input(event: InputEvent, slot: SlotClass):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT && event.pressed:
			if holding_item != null:
				if !slot.item: # Place holding item to slot
					left_click_empty_slot(slot)
				else: # Swap holding item with item in slot
					if holding_item.item_name != slot.item.item_name:
						left_click_different_item(event, slot)
					else: # selbes Item also zusammenführen
						left_click_same_item(slot)	
			elif slot.item:	
				left_click_not_holding(slot)
				slot_wo_mans_her_hat = slot
				
	
func _input(event):
	if holding_item:
		holding_item.global_position = Vector2(get_global_mouse_position().x -16, get_global_mouse_position().y -16)
		if event.is_action_pressed("inventory"):
			close_inventory_holding_item(slot_wo_mans_her_hat)

func left_click_empty_slot(slot: SlotClass):
	player_inv.add_item_to_empty_slot(holding_item, slot)
	slot.putIntoSlot(holding_item)
	holding_item = null
	
func left_click_different_item(event: InputEvent, slot: SlotClass):
	player_inv.remove_item(slot)
	player_inv.add_item_to_empty_slot(holding_item, slot)
	var temp_item = slot.item
	slot.pickFromSolt()
	temp_item.global_position = event.global_position
	slot.putIntoSlot(holding_item)
	holding_item = temp_item
	
func left_click_same_item(slot: SlotClass):
	var stack_size = int(JsonData.item_data[slot.item.item_name]["StackSize"])
	var able_to_add = stack_size - slot.item.item_quantity
	if able_to_add >= holding_item.item_quantity:
		player_inv.add_item_quantity(slot, holding_item.item_quantity)
		slot.item.add_item_quantity(holding_item.item_quantity)
		holding_item.queue_free()
		holding_item = null
	else:
		slot.item.add_item_quantity(able_to_add)
		holding_item.decrease_item_quantity(able_to_add)
		
func left_click_not_holding(slot: SlotClass):
	player_inv.remove_item(slot)
	holding_item = slot.item
	slot.pickFromSolt()
	holding_item.global_position = get_global_mouse_position()
	
func close_inventory_holding_item(slot: SlotClass):
	if holding_item != null:
		player_inv.add_item_to_empty_slot(holding_item, slot)
		slot.putIntoSlot(holding_item)
		holding_item = null
