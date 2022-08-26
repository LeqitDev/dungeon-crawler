extends Control

const SlotClass = preload("res://Scripts/Slot.gd")
onready var inventory_slots = $GridContainer
var holding_item = null

# Called when the node enters the scene tree for the first time.
func _ready():
	for inv_slot in inventory_slots.get_children():
		inv_slot.connect("gui_input", self, "slot_gui_input", [inv_slot])


func slot_gui_input(event: InputEvent, slot: SlotClass):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT && event.pressed:
			if holding_item != null:
				if !slot.item: # Place holding item to slot
					slot.putIntoSlot(holding_item)
					holding_item = null
				else: # Swap holding item with item in slot
					
					if holding_item.item_name != slot.item.item_name:
						var temp_item = slot.item
						slot.pickFromSolt()
						temp_item.global_position = event.global_position
						slot.putIntoSlot(holding_item)
						holding_item = temp_item
						
					else: # selbes Item also zusammenführen
						var stack_size = int(JsonData.item_data[slot.item.item_name]["StackSize"])
						var able_to_add = stack_size - slot.item.item_quantity
						if able_to_add >= holding_item.item_quantity:
							slot.item.add_item_quantity(holding_item.item_quantity)
							holding_item.queue_free()
							holding_item = null
						else:
							slot.item.add_item_quantity(able_to_add)
							holding_item.decrease_item_quantity(able_to_add)
					
			elif slot.item:
				holding_item = slot.item
				slot.pickFromSolt()
				holding_item.global_position = get_global_mouse_position()


func _input(event):
	if holding_item:
		holding_item.global_position = Vector2(get_global_mouse_position().x -16, get_global_mouse_position().y -16)
