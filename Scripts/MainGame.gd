extends Node2D

class_name Game

signal room_update(direction)
signal room_update_done

var max_rooms = 20
var max_rooms_y = 12 # max height of dungeon
export var layer = 2 # layer of the dungeon start = 0; end = 5?
var max_rooms_x = 7 # max width of dungeon
var room_count = 7 # how many rooms there are (min)
var room_map = [] # all rooms in the dungeon (on current layer)
var possible_next_rooms = [] # list of all coords where a new room can spawn
var offspring_bias = 3
var offspring_possibility = 0.95 # 1-this = possibility that new room is not a room on room.x = offspring_bias

var room_pos = Vector2.ZERO

var config

var RoomScene = preload("res://Scenes/DungeonRoom.tscn")

var cursor_image = preload("res://Assets/cursor2.png")

onready var player = $Player

class MapRoom:
	var pos: Vector2
	var passages = [false, false, false, false] # sides where there are pessages to other rooms [left, up, right, down]
	var room: Node2D # room scene
	
	func _init(pos: Vector2):
		self.pos = pos
	
	func finishInit(roomScene: DungeonRoom):
		roomScene.init(passages) # prepare room scene (highways etc.)
		room = roomScene

func _init():
#	OS.window_maximized = false
	config = Config.new()
	VisualServer.texture_set_shrink_all_x2_on_set_data(true)
	VisualServer.set_default_clear_color(Color(0, 0, 0)) # set background black

func _input(event):
	if event.is_action_pressed("ui_debug"):
		config.setProp("debug", !config.getProp("debug"))

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_custom_mouse_cursor(cursor_image,
			Input.CURSOR_ARROW,
			Vector2(64, 64))
	$Player.position = Vector2((Helper.room_width / 2.0) * 32, (Helper.room_height - 1) * 32)
	
	# initialise room_map with 0
	for y in range(max_rooms_y):
		room_map.append([])
		for x in range(max_rooms_x):
			room_map[y].append(null)
	
	# random room count between min room_count and max max_rooms influenced by layer
	room_count += randi() % ((max_rooms - room_count) * layer)
	
	# calc first room (bottom center)
	room_pos = Vector2(max_rooms_x/2, max_rooms_y-1)
	# init first room
	room_map[room_pos.y][room_pos.x] = MapRoom.new(room_pos)
	
	# add surrounding coords left, up, right, down
	add_surrounding_rooms_to_possibles(room_pos)
	
	print("Generating " + str(room_count) + " rooms...\n")
	# create all other rooms
	for i in range(room_count):
		select_next_room()
	
	# call finishinit for all rooms
	for y in range(room_map.size()):
		for x in range(room_map[y].size()):
			if room_map[y][x] != null:
				room_map[y][x].finishInit(RoomScene.instance())
	
	# add the first room scene to the main game scene
	add_child(room_map[room_pos.y][room_pos.x].room)
	move_child(get_child(get_child_count()-1), 0)
#	print_room_map()

func select_next_room():
	# get random possible room index
	var next_room_index = get_next_room(offspring_bias)
	# get new room position
	var next_room_pos = possible_next_rooms[next_room_index]
	possible_next_rooms.remove(next_room_index)
	# instantiate new room
	room_map[next_room_pos.y][next_room_pos.x] = MapRoom.new(next_room_pos)
	# create connection between new room and older room
	create_passage_from_room(next_room_pos)
	# add surrounding coords to possible next rooms
	add_surrounding_rooms_to_possibles(next_room_pos)

func add_surrounding_rooms_to_possibles(room_pos: Vector2):
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
		# room.x is not in a horizontal line with bias (init_room.x)
		var rand = randf()
		if rand < offspring_possibility:
			# 95% try to get other coords
			return get_next_room(bias)
	return next_room_index

func create_passage_from_room(room_pos: Vector2):
	var list = [] # surrounding rooms
	for room in get_surrounding_rooms(room_pos):
		if map_has_room_at(room):
			list.append(room)
	var passage_room = list[randi() % list.size()] # select random room
	var passage_vector = Vector2(passage_room.x - room_pos.x, passage_room.y - room_pos.y)
	match passage_vector:
		Vector2.LEFT:
			room_map[room_pos.y][room_pos.x].passages[0] = true # room passage left
			room_map[passage_room.y][passage_room.x].passages[2] = true # room passage right
		Vector2.UP:
			room_map[room_pos.y][room_pos.x].passages[1] = true # room passage up
			room_map[passage_room.y][passage_room.x].passages[3] = true # room passage down
		Vector2.RIGHT:
			room_map[room_pos.y][room_pos.x].passages[2] = true # room passage right
			room_map[passage_room.y][passage_room.x].passages[0] = true # room passage left
		Vector2.DOWN:
			room_map[room_pos.y][room_pos.x].passages[3] = true # room passage down
			room_map[passage_room.y][passage_room.x].passages[1] = true # room passage up
	
func get_surrounding_rooms(room_pos: Vector2) -> Array:
	var ret = []
	# look for bounds
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

func get_config():
	return config

func _on_MainGame_room_update(direction):
	room_pos += direction
	
	if room_map[room_pos.y][room_pos.x] != null:
		# remove old room
		remove_child(get_child(0))
		# add new room
		add_child(room_map[room_pos.y][room_pos.x].room)
		move_child(get_child(get_child_count()-1), 0)
	else:
		print("no room there")
	
	emit_signal("room_update_done")
