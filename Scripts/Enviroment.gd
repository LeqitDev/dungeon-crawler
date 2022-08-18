extends Node2D


var noise = OpenSimplexNoise.new()
const TileSetManager = preload("res://Scripts/Tiles.gd")
var tiles = null

# Called when the node enters the scene tree for the first time.
func _ready():
	tiles = TileSetManager.new().getTilesList($CampfireOthers)
	
	randomize()
	noise.seed = randi()
	noise.octaves = 10
	noise.period = 0.1
	noise.persistence = 0.75
	for x in range(1, 36):
		for y in range(1, 18):
			if $EdgeHighwayPaths.get_cell(x, y) != -1:
				if "path" in tiles[$EdgeHighwayPaths.get_cell(x, y)]:
					continue
			var point_noise = noise.get_noise_2d(x, y)
			var tile = getTileFromNoise(point_noise)
#			print(str(x) + ", " + str(y) + ": " + str(tile))
			$CampfireOthers.set_cellv(Vector2(x, y), tile)
	pass # Replace with function body.

func getTileFromNoise(point_noise: float) -> int:
	if point_noise < 0.2: return -1
	elif point_noise < 0.44:
		var type = randf()
		if type < 0.8:
			return -1
		elif type < 0.85:
			return TileSetManager.white_flower
		return TileSetManager.blue_flower
	elif point_noise > 0.45:
		var type = randf()
		if type < 0.70:
			return -1
		elif type < 0.95:
			return TileSetManager.berrybush_empty
		return TileSetManager.berrybush
	else: return -1

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
