extends Node2D

# 37, 19

class_name Room

var screen_size
const TileSetManager = preload("res://Scripts/Tiles.gd")

func init(passages):
	if passages[0]:
		$Enviroment/GroundWall.set_cell(0, 10, MyTileSet.left_highway)
		$Enviroment/EdgeHighwayPaths.set_cell(1, 10, MyTileSet.h_path)
		$Enviroment/CampfireOthers.set_cell(1, 10, MyTileSet.left_highway_root)
	else:
		$Enviroment/GroundWall.set_cell(0, 10, MyTileSet.left_forest)
		$Enviroment/EdgeHighwayPaths.set_cell(1, 10, MyTileSet.left_forest_root)
	if passages[1]:
		$Enviroment/GroundWall.set_cell(18, 0, MyTileSet.upper_highway)
		$Enviroment/EdgeHighwayPaths.set_cell(18, 1, MyTileSet.v_path)
		$Enviroment/CampfireOthers.set_cell(18, 1, MyTileSet.upper_highway_root)
	else:
		$Enviroment/GroundWall.set_cell(18, 0, MyTileSet.upper_forest)
		$Enviroment/EdgeHighwayPaths.set_cell(18, 0, MyTileSet.upper_forest_root)
	if passages[2]:
		$Enviroment/GroundWall.set_cell(37, 10, MyTileSet.right_highway)
		$Enviroment/EdgeHighwayPaths.set_cell(36, 10, MyTileSet.h_path)
		$Enviroment/CampfireOthers.set_cell(36, 10, MyTileSet.right_highway_root)
	else:
		$Enviroment/GroundWall.set_cell(37, 10, MyTileSet.right_forest)
		$Enviroment/EdgeHighwayPaths.set_cell(36, 10, MyTileSet.right_forest_root)
	if passages[3]:
		$Enviroment/GroundWall.set_cell(18, 19, MyTileSet.lower_highway)
		$Enviroment/EdgeHighwayPaths.set_cell(18, 18, MyTileSet.v_path)
		$Enviroment/CampfireOthers.set_cell(18, 18, MyTileSet.lower_highway_root)
	else:
		$Enviroment/GroundWall.set_cell(18, 19, MyTileSet.lower_forest)
		$Enviroment/EdgeHighwayPaths.set_cell(18, 18, MyTileSet.lower_forest_root)
	
	$Enviroment/CampfireOthers.set_cell(37 / 2, 19 / 2, MyTileSet.campfire_off)

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport().size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
