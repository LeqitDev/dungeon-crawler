extends Node2D

# 37, 19

class_name DungeonRoom
signal drop_item

var screen_size
const TileSetManager = preload("res://Scripts/Tiles.gd")
var ItemDrop = preload("res://Scripts/ItemDrop.gd")

var rng = RandomNumberGenerator.new()


func init(passages):
	# generating top and bottom border
	for x in range(1, Helper.room_width):
		for y in [0, Helper.room_height]:
			if y == 0:
				$Enviroment/Layer0.set_cell(x, y, MyTileSet.upper_forest)
				$Enviroment/Layer1.set_cell(x, y + 1, MyTileSet.upper_forest_root)
			else:
				$Enviroment/Layer0.set_cell(x, y, MyTileSet.lower_forest)
				$Enviroment/Layer1.set_cell(x, y - 1, MyTileSet.lower_forest_root)
	
	# generating left and right border
	for y in range(1, Helper.room_height):
		for x in [0, Helper.room_width]:
			if x == 0:
				$Enviroment/Layer0.set_cell(x, y, MyTileSet.left_forest)
				$Enviroment/Layer1.set_cell(x + 1, y, MyTileSet.left_forest_root)
			else:
				$Enviroment/Layer0.set_cell(x, y, MyTileSet.right_forest)
				$Enviroment/Layer1.set_cell(x - 1, y, MyTileSet.right_forest_root)
	
	var i = 0
	var forest_edges = [MyTileSet.upper_left_forest, MyTileSet.lower_left_forest, MyTileSet.upper_right_forest, MyTileSet.lower_right_forest]
	var root_edges = [MyTileSet.upper_left_root, MyTileSet.lower_left_root, MyTileSet.upper_right_root, MyTileSet.lower_right_root]
	# generating edges
	for x in [0, Helper.room_width]:
		for y in [0, Helper.room_height]:
			$Enviroment/Layer0.set_cell(x, y, forest_edges[i])
			var root_pos = Vector2(x, y)
			if x == 0: root_pos += Vector2(1, 0)
			else: root_pos += Vector2(-1, 0)
			if y == 0: root_pos += Vector2(0, 1)
			else: root_pos += Vector2(0, -1)
			$Enviroment/Layer1.set_cellv(root_pos, root_edges[i])
			i += 1
	
	#generating grass
	for x in range(1, Helper.room_width):
		for y in range(1, Helper.room_height):
			$Enviroment/Layer0.set_cell(x, y, MyTileSet.grass, Helper.randomBool(0.1), Helper.randomBool(0.1))
	
	# Placing the campfire in the middle
	$Enviroment/Layer1.set_cell(int(Helper.room_width / 2.0), int(Helper.room_height / 2.0), MyTileSet.campfire_off)
	
	# Creating the Higways left, top, right, bottom
	if passages[0]:
		$Enviroment/Layer0.set_cell(0, Helper.room_height / 2, MyTileSet.left_highway)
		$Enviroment/Layer1.set_cell(1, Helper.room_height / 2, MyTileSet.h_path)
		$Enviroment/Layer2.set_cell(1, Helper.room_height / 2, MyTileSet.left_highway_root)
	if passages[1]:
		$Enviroment/Layer0.set_cell(Helper.room_width / 2, 0, MyTileSet.upper_highway)
		$Enviroment/Layer1.set_cell(Helper.room_width / 2, 1, MyTileSet.v_path)
		$Enviroment/Layer2.set_cell(Helper.room_width / 2, 1, MyTileSet.upper_highway_root)
	if passages[2]:
		$Enviroment/Layer0.set_cell(Helper.room_width, Helper.room_height / 2, MyTileSet.right_highway)
		$Enviroment/Layer1.set_cell(Helper.room_width - 1, Helper.room_height / 2, MyTileSet.h_path)
		$Enviroment/Layer2.set_cell(Helper.room_width - 1, Helper.room_height / 2, MyTileSet.right_highway_root)
	if passages[3]:
		$Enviroment/Layer0.set_cell(Helper.room_width / 2, Helper.room_height, MyTileSet.lower_highway)
		$Enviroment/Layer1.set_cell(Helper.room_width / 2, Helper.room_height - 1, MyTileSet.v_path)
		$Enviroment/Layer2.set_cell(Helper.room_width / 2, Helper.room_height - 1, MyTileSet.lower_highway_root)

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().root.get_child(0).connect("room_update_done", self, "updateRoomFinished")
	self.connect("drop_item", self, "on_item_drop_signal")
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func updateRoomFinished():
	get_node("Campfire").emit_signal("play_lit_animation", Vector2.ZERO)

func on_item_drop_signal(itemname, amount, pos):
	
	if itemname != "chest":
		if amount == 1:
			var instance = load("res://Scenes/ItemDrop.tscn").instance()
			self.add_child(instance)
			instance.emit_signal("initItem", itemname)
			instance.position = pos
	else:
		var items = {
			1: "Sword",
			2: "SwordII",
			3: "SwordIII",
			4: "SwordIV",
			5: "SwordV",
			6: "Arrow",
			7: "Redberry",
			8: "Axe",
			9: "AxeII",
			10: "AxeIII",
			11: "AxeIV",
			12: "AxeV",
			13: "Coin"
		}
		rng.randomize()
		var value = -1
		var random_amount = rng.randi()%3+1
		for n in random_amount:
			var random_number = rng.randf_range(0, 100)
			var item = 1
			
			if random_number > 95:
				item = 5
			elif random_number > 90 and random_number <= 95:
				item = 4
			elif random_number > 85 and random_number <= 90:
				item = 3
			elif random_number > 75 and random_number <= 85:
				var other_random = rng.randi()%3+1
				if other_random == 1:
					item = 2
				elif other_random == 2:
					item = 8
				elif other_random == 3:
					item = 7
			elif random_number > 50 and random_number <= 75:
				var other_random = rng.randi()%2+1
				if other_random == 1:
					item = 1
				elif other_random == 2:
					item = 6
			elif random_number < 50:
				item = 9
	
			var instance = load("res://Scenes/ItemDrop.tscn").instance()
			self.add_child(instance)
			instance.emit_signal("initItem", items[item])
			var fixedpos = Vector2(pos.x + (30*value),pos.y)
			instance.position = fixedpos
			value += 1
