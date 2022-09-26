extends Node2D

# 37, 19

class_name DungeonRoom
signal drop_item

var screen_size
const TileSetManager = preload("res://Scripts/Tiles.gd")
var ItemDrop = preload("res://Scripts/ItemDrop.gd")
var Enemy = preload("res://Scenes/Enemy.tscn")
var Chest = preload("res://Scenes/Chest.tscn")

var enemys = 0
var room_locked = true

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
			var rand = randf()
			var grass = MyTileSet.grass
			if rand > 0.94 and rand <= 0.99:
				grass = MyTileSet.grass_1
			elif rand > 0.99 and rand <= 1:
				grass = MyTileSet.grass_3
			$Enviroment/Layer0.set_cell(x, y, grass)
	
	# Placing the campfire in the middle
	$Enviroment/Layer2.set_cell(int(Helper.room_width / 2.0), int(Helper.room_height / 2.0), MyTileSet.campfire_off)
	
#	$Enviroment/Layer1.set_cell(int(Helper.room_width / 2.0), int(Helper.room_height / 2.0), MyTileSet.plaza)
	var j = 0
	for y in range(int(Helper.room_height / 2.0) - 1, int(Helper.room_height / 2.0) + 2):
		for x in range(int(Helper.room_width / 2.0) - 1, int(Helper.room_width / 2.0) + 2):
			if $Enviroment/Layer1.get_cell(x, y) == -1:
				$Enviroment/Layer1.set_cell(x, y, MyTileSet.plaza_group[j])
			j += 1
	
	# Creating the Higways left, top, right, bottom
	if passages[0]:
		$Enviroment/Layer0.set_cell(0, Helper.room_height / 2, MyTileSet.left_highway)
		$Enviroment/Layer1.set_cell(1, Helper.room_height / 2, MyTileSet.h_path)
		for p in range(1, int(Helper.room_width / 2.0) - 1):
			$Enviroment/Layer1.set_cell(p, Helper.room_height / 2, MyTileSet.h_path)
		$Enviroment/Layer1.set_cell(int(Helper.room_width / 2.0) - 1, int(Helper.room_height / 2.0), MyTileSet.plaza_left_path)
		$Enviroment/Layer2.set_cell(1, Helper.room_height / 2, MyTileSet.left_highway_root)
	if passages[1]:
		$Enviroment/Layer0.set_cell(Helper.room_width / 2, 0, MyTileSet.upper_highway)
		$Enviroment/Layer1.set_cell(Helper.room_width / 2, 1, MyTileSet.v_path)
		for p in range(1, int(Helper.room_height / 2.0) - 1):
			$Enviroment/Layer1.set_cell(Helper.room_width / 2, p, MyTileSet.v_path)
		$Enviroment/Layer1.set_cell(int(Helper.room_width / 2.0), int(Helper.room_height / 2.0) - 1, MyTileSet.plaza_upper_path)
		$Enviroment/Layer2.set_cell(Helper.room_width / 2, 1, MyTileSet.upper_highway_root)
	if passages[2]:
		$Enviroment/Layer0.set_cell(Helper.room_width, Helper.room_height / 2, MyTileSet.right_highway)
		$Enviroment/Layer1.set_cell(Helper.room_width - 1, Helper.room_height / 2, MyTileSet.h_path)
		for p in range(int(Helper.room_width / 2.0) + 1, Helper.room_width - 1):
			$Enviroment/Layer1.set_cell(p, Helper.room_height / 2, MyTileSet.h_path)
		$Enviroment/Layer1.set_cell(int(Helper.room_width / 2.0) + 1, int(Helper.room_height / 2.0), MyTileSet.plaza_right_path)
		$Enviroment/Layer2.set_cell(Helper.room_width - 1, Helper.room_height / 2, MyTileSet.right_highway_root)
	if passages[3]:
		$Enviroment/Layer0.set_cell(Helper.room_width / 2, Helper.room_height, MyTileSet.lower_highway)
		$Enviroment/Layer1.set_cell(Helper.room_width / 2, Helper.room_height - 1, MyTileSet.v_path)
		for p in range(int(Helper.room_height / 2.0) + 1, Helper.room_height - 1):
			$Enviroment/Layer1.set_cell(Helper.room_width / 2, p, MyTileSet.v_path)
		$Enviroment/Layer1.set_cell(int(Helper.room_width / 2.0), int(Helper.room_height / 2.0) + 1, MyTileSet.plaza_lower_path)
		$Enviroment/Layer2.set_cell(Helper.room_width / 2, Helper.room_height - 1, MyTileSet.lower_highway_root)
	
	# how many Enemys min. 1 max. 5
	enemys = (randi() % 4) + 1

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().root.get_child(0).connect("room_update_done", self, "updateRoomFinished")
	self.connect("drop_item", self, "on_item_drop_signal")
	
	# spawn enemys
	for i in range(enemys):
		var local_enemy = Enemy.instance()
		local_enemy.position = Vector2((randi() % 321) + 32, (randi() % 321) + 32)
		local_enemy.connect("die", self, "on_enemy_dies") # connect with enemy
		$Enemys.add_child(local_enemy)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func is_room_locked() -> bool:
	return room_locked

func updateRoomFinished():
	get_node("Campfire").emit_signal("play_lit_animation", Vector2.ZERO)

func on_enemy_dies(): # enemy dies one enemy less
	enemys -= 1;
	if enemys < 1: # no more enemys
		room_locked = false # unlock room
		var chest = Chest.instance()
		chest.position = get_tree().root.get_node("MainGame/Player").get_position()
		add_child(chest)

func on_item_drop_signal(itemname, amount, pos):
	
	if itemname != "chest":
		if amount == 1:
			var instance = load("res://Scenes/ItemDrop.tscn").instance()
			self.add_child(instance)
			instance.emit_signal("initItem", itemname)
			instance.position = pos
	else:
		var commonItems = {
			0: "Sword",
			1: "Coin",
			2: "Arrow",
			3: "Axe",
			4: "Redberry"
		}
		
		var uncommonItems = {
			0: "SwordII",
			1: "AxeII"
		}
		
		var rareItems = {
			1: "SwordIII",
			2: "AxeIII"
		}
		
		var mythicItems = {
			1: "SwordIV",
			2: "AxeIV"
		}
		
		
		rng.randomize()
		var value = -1
		var random_amount = rng.randi()%3+1
		for n in random_amount:
			var item
			
			var length = commonItems.size()
			var random = rng.randi()%(length)
			item = commonItems[random]

			var instance = load("res://Scenes/ItemDrop.tscn").instance()
			self.add_child(instance)
			instance.emit_signal("initItem", item)
			var fixedpos = Vector2.ZERO
			if random_amount == 3:
				fixedpos = Vector2(pos.x + (30*value),pos.y)
				value += 1
			elif random_amount == 2:
				fixedpos = Vector2(pos.x + (15*value),pos.y)
				value += 2
			elif random_amount == 1:
				fixedpos = Vector2(pos.x,pos.y)
			instance.position = fixedpos
