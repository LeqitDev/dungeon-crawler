extends Node

class_name MyTileSet

const berrybush = 36
const berrybush_empty = 35
const blue_flower = 45
const campfire_lit = 54
const campfire_off = 53
const cross_path = 15
const triple_v_path_bloom = 43
const double_v_path_bloom = 46
const upper_v_path_bloom = 47
const lower_v_path_bloom = 48
const left_h_path_bloom = 49
const right_h_path_bloom = 50
const double_h_path_bloom = 51
const triple_h_path_bloom = 52
const grass = 42
const h_lower_path = 27
const h_path = 14
const h_upper_path = 28
const left_forest = 20
const left_forest_root = 21
const left_highway = 38
const left_highway_path = 11
const left_highway_root = 8
const lower_forest = 39
const lower_forest_root = 32
const lower_highway = 55
const lower_highway_path = 16
const lower_highway_root = 9
const lower_left_forest = 41
const lower_left_path = 19
const lower_left_root = 2
const lower_right_forest = 40
const lower_right_path = 26
const lower_right_root = 3
const right_forest = 24
const right_forest_root = 23
const right_hayway_path = 12
const right_highway = 34
const right_highway_root = 7
const upper_forest = 4
const upper_forest_root = 5
const upper_highway = 33
const upper_highway_path = 10
const upper_highway_root = 6
const upper_left_forest = 30
const upper_left_path = 25
const upper_left_root = 0
const upper_right_forest = 31
const upper_right_path = 29
const upper_right_root = 1
const v_path = 13
const v_right_path = 18
const white_flower = 44
const grass_3 = 59
const grass_2 = 58
const grass_1 = 57
const plaza_upper_left_edge = 61
const plaza_upper_edge = 62
const plaza_upper_right_edge = 67
const plaza_left_edge = 60
const plaza = 63
const plaza_right_edge = 66
const plaza_lower_left_edge = 50
const plaza_lower_edge = 64
const plaza_lower_right_edge = 65
const plaza_lower_path = 10
const plaza_left_path = 12
const plaza_right_path = 11
const plaza_upper_path = 16


const highway_group = [left_highway, upper_highway, right_highway, lower_highway]
const plaza_group = [plaza_upper_left_edge, plaza_upper_edge, plaza_upper_right_edge, plaza_left_edge, plaza, plaza_right_edge, plaza_lower_left_edge, plaza_lower_edge, plaza_lower_right_edge]

class Tile:
	var tilemap: TileMap
	var tile: int
	var pos: Vector2
	
	func _init(tilemap: TileMap, tile: int, pos: Vector2):
		self.tilemap = tilemap
		self.tile = tile
		self.pos = pos

static func getTilesList(tile_map:TileMap) -> Dictionary:
	var tiles = {}
	for i in tile_map.tile_set.get_tiles_ids():
		tiles[i] = tile_map.tile_set.tile_get_name(i)
	return tiles

static func setCell(map: TileMap, x: int, y: int, tile: int):
	map.set_cell(x, y, tile)
