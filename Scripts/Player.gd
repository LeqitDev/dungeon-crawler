extends KinematicBody2D

signal lit_torch

# playerspeed (movement)
export var speed = 400
var screen_size

# torch flicker
onready var noise = OpenSimplexNoise.new()
var value = 0.0
const MAX_VALUE = 100000000

var BuschGefunden = false

var inside_area = []
var interactable_tiles = [MyTileSet.berrybush, MyTileSet.berrybush_empty, MyTileSet.campfire_off] + MyTileSet.highway_group

# get gui screen
onready var gui = get_parent().get_node("Control/Control")
onready var tween = get_node("Tween")

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport().size
	
	get_tree().root.get_child(0).connect("room_update_done", self, "updateRoomFinished")
	emit_signal("lit_torch")
	randomize()
	value = randi() % MAX_VALUE
	noise.period = 16


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# int for interact signal "E"-Button
	var interact_signal = 0
	
	# postion offset for ux
	var fixed_pos = Vector2(position.x, position.y+32)
	
	# needs to be empty every new frame
	var tiles_inside_area = []
	var tiles_inside_area_details = []
	
	# movement
	
	var sound_has_played = false
	var pos = Vector2.ZERO
	if Input.is_action_pressed("ui_left"):
		pos.x -= 1
		if !sound_has_played:
			sound_has_played = true
			$Footsteps.play()
	if Input.is_action_pressed("ui_up"):
		pos.y -= 1
		if !sound_has_played:
			sound_has_played = true
			$Footsteps.play()
	if Input.is_action_pressed("ui_right"):
		pos.x += 1
		if !sound_has_played:
			sound_has_played = true
			$Footsteps.play()
	if Input.is_action_pressed("ui_down"):
		pos.y += 1
		if !sound_has_played:
			sound_has_played = true
			$Footsteps.play()
	
	if pos.length() > 0: # on movement
		$AnimationPlayer.playback_speed = 1.75 # play walk animations faster
		var direction = Helper.direction_group.find(pos)
		$AnimationPlayer.play(Helper.direction_player_animation[direction]) # play the walk animation for the direction
		pos = pos.normalized() * speed # calculate position with speed
		$AnimationPlayerLight.playback_speed = 2.5 # animation speed for light so it flickers more
	else: # no movement
		# normal player and light animationspeed
		$AnimationPlayer.playback_speed = 1
		$AnimationPlayerLight.playback_speed = 1
		$AnimationPlayer.play("PlayerIdle") # idle player animation
	
	pos = move_and_slide(pos) # move player (get new position)
	
	# get collided tile (CollisionShape2D)
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider is TileMap:
			var tilemap = collision.collider as TileMap
			var collision_position = collision.position - collision.normal
			var tile_pos = Vector2(int(collision_position.x / 32), int(collision_position.y / 32))
			var tile_id = tilemap.get_cellv(tile_pos)
	
	for x in range(-1, 2):
		for y in range(-1, 2):
			var tilemaps = ["Layer0", "Layer1", "Layer2"] # all tilemap objects
			for tilemap in tilemaps:
				if has_area2d_object(tilemap):
					var tilemap_obj = get_area2d_object(tilemap)
					var tile_pos_wrld = Vector2(fixed_pos.x + x * 32, fixed_pos.y + y * 32)
					
					var tile_pos = tilemap_obj.world_to_map(tile_pos_wrld) # get tile pos from player pos
					var tile = tilemap_obj.get_cellv(tile_pos) # get tile
					
					if tile in interactable_tiles: # if tile is a tile which the player can interact with
						tiles_inside_area.append(tile) # add tile to tiles inside area list
						tiles_inside_area_details.append(MyTileSet.Tile.new(tilemap_obj, tile, tile_pos)) # add tile details to detailed tiles list
	
	if MyTileSet.campfire_off in tiles_inside_area: # check for campfire (off)
		interact_signal += 1 # show "E" interact key 
		if Input.is_action_just_pressed("ui_interact"): # has campfire and "E" pressed
			var tile_obj = tiles_inside_area_details[tiles_inside_area.find(MyTileSet.campfire_off)] # get more details about the tile (tilemap, position)
			tile_obj.tilemap.set_cellv(tile_obj.pos, MyTileSet.campfire_lit) # set campfire to lit campfire
			get_parent().get_node("Room/Campfire").emit_signal("play_lit_animation", tile_obj.pos * 32) # set position of campfire light
	
	if MyTileSet.berrybush in tiles_inside_area: # check for berrybushes
		interact_signal += 1 # show "E" interact key
		BuschGefunden = true
	
	if BuschGefunden == true:
		BuschGefunden = false
	
	for highway in MyTileSet.highway_group: # check for highways
		if highway in tiles_inside_area:
			interact_signal += 1 # show "E" interact key 
			if Input.is_action_just_pressed("ui_interact"): # has highways and "E" pressed
				var highway_i = MyTileSet.highway_group.find(highway) # get which highway it was left, top, etc
				get_parent().emit_signal("room_update", Helper.direction_group[highway_i]) # update the room to the new one
				position = Helper.direction_spawnpoints[highway_i] * 32 + Vector2(16, 8) # set new Player position
	
	gui.emit_signal("key_popup", "E", self.position, interact_signal > 0) # "E" key popup

func _on_Area2D_body_entered(body):
	if !inside_area.has(body) and body != self:
		inside_area.append(body)

func _on_Area2D_body_exited(body):
	inside_area.remove(inside_area.find(body))

func get_area2d_object(name):
	for obstacle in inside_area:
		if obstacle.name == name:
			return obstacle
	return null

func has_area2d_object(name):
	for obstacle in inside_area:
		if obstacle.name == name:
			return true
	return false

func _physics_process(delta):
	# flicker torch light
	value += 0.5
	if value > MAX_VALUE:
		value = 0.0
	var alpha = ((noise.get_noise_1d(value) + 1) / 4.0) + 0.5
	var color = $Light2D.color
	$Light2D.color = Color(color.r, color.g, color.b, alpha) # change alpha color to random between 0.5 and 1.0 for flicker

func _on_Player_lit_torch():
	# Torchlight animation
	$AnimationPlayerLight.stop()
	$AnimationPlayerLight.play("LitTorchAnimation")
#	$AnimationPlayerLight.queue("TorchLightAnimations")

func updateRoomFinished():
	emit_signal("lit_torch")
