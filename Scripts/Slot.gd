extends Panel

var default_tex = preload("res://Assets/gui/inventory/item_slot_default_background.png")
var empty_tex = preload("res://Assets/gui/inventory/item_slot_empty_background.png")
var hotbar_tex = preload("res://Assets/gui/hotbar/hotbar_normal.png")
var selected_tex = preload("res://Assets/gui/hotbar/hotbar_active.png")

var default_style: StyleBoxTexture = null
var empty_style: StyleBoxTexture = null
var hotbar_style: StyleBoxTexture = null
var selected_style: StyleBoxTexture = null


var ItemClass = preload("res://Scenes/Item.tscn")
var item = null
var slot_index
var slot_type

enum SlotType {
	HOTBAR = 0,
	INVENTORY,
}

func _ready():
	default_style = StyleBoxTexture.new()
	empty_style = StyleBoxTexture.new()
	hotbar_style = StyleBoxTexture.new()
	selected_style = StyleBoxTexture.new()
	default_style.texture = default_tex
	empty_style.texture = empty_tex
	hotbar_style.texture = hotbar_tex
	selected_style.texture = selected_tex
	
	
	
	
#	if randi() % 2 == 0:
#		item = ItemClass.instance()
#		add_child(item)
	refresh_style()

func refresh_style():
	if SlotType.HOTBAR == slot_type and PlayerInventory.active_item_slot == slot_index:
		set('custom_styles/panel', selected_style)
	elif SlotType.HOTBAR == slot_type and PlayerInventory.active_item_slot != slot_index:
		set('custom_styles/panel', hotbar_style)
	elif item == null:
		set('custom_styles/panel', empty_style)
	else:
		set('custom_styles/panel', default_style)


func pickFromSolt():
	remove_child(item)
	var inventoryNode = find_parent("Control")
	inventoryNode.add_child(item)
	item = null
	refresh_style()
	
func putIntoSlot(new_item):
	item = new_item
	item.position = Vector2(0, 0)
	var inventoryNode = find_parent("Control")
	inventoryNode.remove_child(item)
	add_child(item)
	refresh_style()


func initialize_item(item_name, item_quantity):
	if item == null:
		item = ItemClass.instance()
		add_child(item)
		item.set_item(item_name, item_quantity)
	else:
		item.set_item(item_name, item_quantity)
	refresh_style()
