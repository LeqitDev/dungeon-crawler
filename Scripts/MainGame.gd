extends Node2D

signal room_update(direction)

var min_rooms = 7
var max_rooms_y = 12
var layer = 2
var max_rooms_x = 7
var room_count = 20
var room_map = []
var possible_next_rooms = []
var offspring_bias = 3
var offspring_possibility = 0.95 # 0.95 is perfect i think

var room_pos = Vector2.ZERO

var RoomScene = preload("res://Scenes/MainScene.tscn")

class MapRoom:
	var pos: Vector2
	var passages = [false, false, false, false]
	var room: Node2D
	
	func _init(pos: Vector2):
		self.pos = pos
	
	func finishInit(roomScene: MyRoom):
		roomScene.init(passages)
		room = roomScene

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# initialise room_map with 0
	for y in range(max_rooms_y):
		room_map.append([])
		for x in range(max_rooms_x):
			room_map[y].append(null)
	
	room_count += randi() % ((max_rooms_y - min_rooms) * layer)
	
	room_pos = Vector2(max_rooms_x/2, max_rooms_y-1)
	room_map[room_pos.y][room_pos.x] = MapRoom.new(room_pos)
	
	add_rooms_to_possibles(room_pos)
	
	print("Generating " + str(room_count) + " rooms...\n")
	for i in range(room_count):
		select_next_room()
	
	for y in range(room_map.size()):
		for x in range(room_map[y].size()):
			if room_map[y][x] != null:
				room_map[y][x].finishInit(RoomScene.instance())
	
	add_child(room_map[room_pos.y][room_pos.x].room)
	move_child(get_child(2), 0)
	
#	print_room_map()

func select_next_room():
	var next_room_index = get_next_room(offspring_bias)
	var next_room_pos = possible_next_rooms[next_room_index]
	possible_next_rooms.remove(next_room_index)
	room_map[next_room_pos.y][next_room_pos.x] = MapRoom.new(next_room_pos)
	create_passage_from_room(next_room_pos)
	add_rooms_to_possibles(next_room_pos)

func add_rooms_to_possibles(room_pos: Vector2):
	for room in get_surrounding_rooms(room_pos):
		if !map_has_room_at(room):
			possible_next_rooms.append(room)

func map_has_room_at(room_pos: Vector2) -> bool:
	if room_map[room_pos.y][room_pos.x] != null:
		return true
	return false

func get_next_room(bias: int) -> int:
	var next_room_index = randi() % possible_next_rooms.size()
	var next_room_pos = possible_next_rooms[next_room_index]
	if next_room_pos.x != bias:
		var rand = randf()
		if rand < offspring_possibility:
			return get_next_room(bias)
	return next_room_index

func create_passage_from_room(room_pos: Vector2):
	var list = []
	for room in get_surrounding_rooms(room_pos):
		if map_has_room_at(room):
			list.append(room)
	var passage_room = list[randi() % list.size()]
	var passage_vector = Vector2(passage_room.x - room_pos.x, passage_room.y - room_pos.y)
	match passage_vector:
		Vector2.LEFT:
			room_map[room_pos.y][room_pos.x].passages[0] = true
			room_map[passage_room.y][passage_room.x].passages[2] = true
		Vector2.UP:
			room_map[room_pos.y][room_pos.x].passages[1] = true
			room_map[passage_room.y][passage_room.x].passages[3] = true
		Vector2.RIGHT:
			room_map[room_pos.y][room_pos.x].passages[2] = true
			room_map[passage_room.y][passage_room.x].passages[0] = true
		Vector2.DOWN:
			room_map[room_pos.y][room_pos.x].passages[3] = true
			room_map[passage_room.y][passage_room.x].passages[1] = true
	
func get_surrounding_rooms(room_pos: Vector2) -> Array:
	var ret = []
	if room_pos.x != max_rooms_x-1:
		var next_room_pos = room_pos + Vector2.RIGHT
		ret.append(next_room_pos)
	if room_pos.x != 0:
		var next_room_pos = room_pos + Vector2.LEFT
		ret.append(next_room_pos)
	if room_pos.y != max_rooms_y-1:
		var next_room_pos = room_pos + Vector2.DOWN
		ret.append(next_room_pos)
	if room_pos.y != 0:
		var next_room_pos = room_pos + Vector2.UP
		ret.append(next_room_pos)
	return ret

func print_room_map():
	var y_c = 0
	
	var max_index_y = room_map.size()
	var max_index_x = room_map[0].size()
	var char_width_y = str(max_index_y).length() + 1
	var char_width_x = str(max_index_x).length() + 1
	
	
	var x:String = " "
	for i in range(char_width_y):
		x += " "
	for i in range((room_map[0] as Array).size()):
		var space = ","
		for s in range(char_width_x - str(i).length()):
			space += " "
		x += str(i) + space
	print(x + "\n")
	
	for y in room_map:
		var space = " "
		for i in range(char_width_y - str(y_c).length()):
			space += " "
		print(str(y_c) + space + get_map_row(y, char_width_x))
		y_c += 1

func get_map_row(row, char_width_x) -> String:
	var ret = ""
	var index = 0
	for r in row:
		var space = ","
		var special = 0
		if (index+1) % 10 == 0:
			special = 1
		for i in range(char_width_x - 1 + special):
			space += " "
		ret += str(r)
		index += 1
		if index != row.size():
			ret += space
	return ret

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_MainGame_room_update(direction):
	room_pos += direction
	
	print("New Room Position: " + str(room_pos))
	
	if room_map[room_pos.y][room_pos.x] != null:
		remove_child(get_child(0))
		add_child(room_map[room_pos.y][room_pos.x].room)
		move_child(get_child(2), 0)
	else:
		print("no room there")
