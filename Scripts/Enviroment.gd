extends Node2D

# TilemapLayers and Objects on them:
# Layer 0:
#	 Border (Forest, Highways)
#	 Grass
# Layer 1:
#	 Roots (Border/Forest)
#	 Paths
#	 Campfire
# Layer 2:
#	 Flowers
#	 Bushes
#	 Roots (Highway)


var noise = OpenSimplexNoise.new()
#var tiles = null

# Called when the node enters the scene tree for the first time.
func _ready():
#	tiles = MyTileSet.getTilesList($CampfireOthers)
	
	randomize()
	noise.seed = randi()
	noise.octaves = 9
	noise.period = 0.1
	noise.persistence = 0.75
	for x in range(1, Helper.room_width - 1):
		for y in range(1, Helper.room_height - 1):
			if $Layer1.get_cell(x, y) != -1 or $Layer2.get_cell(x, y) != -1:
				continue
			
			var point_noise = noise.get_noise_2d(x, y)
			generateTileAtPosition(x, y, point_noise)
	pass # Replace with function body.

func generateTileAtPosition(x: int, y: int, noise: float):
	if noise < 0.3: return
	if noise < 0.375:
		if Helper.randomBool(0.26): # 25%
			generateFlowerGroup(x, y, MyTileSet.white_flower)
		else: # 75%
			generateFlowerGroup(x, y, MyTileSet.blue_flower)
	else:
		if Helper.randomBool(0.2): MyTileSet.setCell($Layer2, x, y, MyTileSet.berrybush) # bush with berries
		else: MyTileSet.setCell($Layer2, x, y, MyTileSet.berrybush_empty) # bush without berries

func generateFlowerGroup(x: int, y: int, tile: int):
	for x_i in range(x - 1, x + 2):
		for y_i in range(y - 1, y + 2):
			if isTileAtPos(x_i, y_i): continue
			var distance = sqrt(pow(x_i - x, 2) + pow(y_i - y, 2))
			if distance == 0:
				MyTileSet.setCell($Layer2, x_i, y_i, tile) # in the center just place flower
				return
			if distance == 1:
				Helper.randomExec(0.31, funcref(MyTileSet, "setCell"), [$Layer2, x_i, y_i, tile]) # cross with possibility of 30% flower
			else:
				Helper.randomExec(0.16, funcref(MyTileSet, "setCell"), [$Layer2, x_i, y_i, tile]) # diagonal with possibility of 15% flower

func isTileAtPos(x: int, y: int):
	return ($Layer1.get_cell(x, y) != -1 or $Layer2.get_cell(x, y) != -1)
