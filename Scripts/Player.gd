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
var BuschTilePos = null
var BuschObj = null

var inside_area = []
var interactable_tiles = [MyTileSet.berrybush, MyTileSet.berrybush_empty, MyTileSet.campfire_off] + MyTileSet.highway_group
var inside_combat_area = []

var can_attack = false

# get gui screen
onready var gui = get_parent().get_node("Control/Control")

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport().size
	
	get_tree().root.get_child(0).connect("room_update_done", self, "updateRoomFinished")
	emit_signal("lit_torch")
	randomize()
	value = randi() % MAX_VALUE
	noise.period = 16
	

func _input(event):
	# attack
	if event.is_action_pressed("ui_mouse_left") and can_attack:
		var inv = get_tree().root.get_node("/root/MainGame/Control/Control/Inventory")
		if ! inv.visible == true:
			for obj in inside_combat_area:
				obj.emit_signal("combat", self, JsonData.item_data[PlayerInventory.get_active_item()]["ItemDamage"])
			$AttackCooldown.start(JsonData.item_data[PlayerInventory.get_active_item()]["ItemSpeed"]) # start attack cooldown
			can_attack = false
	
	# pick up items
	if event.is_action_pressed("pickup"):
		if $PickupZone.items_in_range.size() > 0:
			var pickup_item = $PickupZone.items_in_range.values()[0]
			
			pickup_item.pick_up_item(self, pickup_item)
			$PickupZone.items_in_range.erase(pickup_item)
		
	if event.is_action_pressed("ui_interact"):
		if BuschGefunden == true:
			BuschObj.tilemap.set_cell(BuschTilePos.x, BuschTilePos.y, MyTileSet.berrybush_empty)
			get_parent().get_node("Room").emit_signal("drop_item", "Redberry", 1, Vector2(position.x , position.y - 30))
	if event.is_action_pressed("change_slot"):
		PlayerInventory.active_item_change()
		if PlayerInventory.get_active_item() != null:
			$Sprites/WeaponSprite.texture = PlayerInventory.textures[PlayerInventory.get_active_item()]
			
			#Rumprobieren mit Particles(einach ignorieren)
			if PlayerInventory.get_active_item() == "SwordV":
				get_node("Sprites/WeaponSprite/Particles2D").visible = true
				get_node("Sprites/WeaponSprite/Particles2D").modulate = Color(0,1,0)
			elif PlayerInventory.get_active_item() == "SwordIV":
				get_node("Sprites/WeaponSprite/Particles2D").visible = true
				get_node("Sprites/WeaponSprite/Particles2D").modulate = Color(1,0,0)
			elif PlayerInventory.get_active_item() == "SwordIII":
				get_node("Sprites/WeaponSprite/Particles2D").visible = true
				get_node("Sprites/WeaponSprite/Particles2D").modulate = Color(0,0,1)
			elif PlayerInventory.get_active_item() == "SwordII":
				get_node("Sprites/WeaponSprite/Particles2D").visible = true
				get_node("Sprites/WeaponSprite/Particles2D").modulate = Color(1,1,0)
			else:
				get_node("Sprites/WeaponSprite/Particles2D").visible = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# int for interact signal "E"-Button
	var interact_signal = 0
	var interact_signal_objects = []
	
	# postion offset for ux needs to be updated every frame
	var fixed_pos = Vector2(position.x, position.y)
	
	# needs to be empty every new frame
	var tiles_inside_area = []
	var tiles_inside_area_details = []
	
	# movement
	var walking = false
	var pos = Vector2.ZERO
	if Input.is_action_pressed("ui_left"):
		walking = true
		pos.x -= 1
	if Input.is_action_pressed("ui_up"):
		walking = true
		pos.y -= 1
	if Input.is_action_pressed("ui_right"):
		walking = true
		pos.x += 1
	if Input.is_action_pressed("ui_down"):
		walking = true
		pos.y += 1
		
	if walking == true:
		if !$Footsteps.playing:
			$Footsteps.play()
	else:
		if $Footsteps.playing:
			$Footsteps.stop()
		
	
	
	if pos.length() > 0: # on movement
		$AnimationPlayer.playback_speed = 1.75 # play walk animations faster
		$AnimationPlayerWeapon.playback_speed = 1.75
		var direction = Helper.direction_group.find(pos)
		$AnimationPlayer.play(Helper.direction_player_animation[direction]) # play the walk animation for the direction
		$AnimationPlayerWeapon.play(Helper.direction_player_weapon_animation[direction])
		pos = pos.normalized() * speed # calculate position with speed
		$AnimationPlayerLight.playback_speed = 2.5 # animation speed for light so it flickers more
	else: # no movement
		# normal player and light animationspeed
		$AnimationPlayer.playback_speed = 1
		$AnimationPlayerWeapon.playback_speed = 1
		$AnimationPlayerLight.playback_speed = 1
		$AnimationPlayer.play("PlayerIdle") # idle player animation
		$AnimationPlayerWeapon.play("Idle")
	
	pos = move_and_slide(pos) # move player (get new position)
	
	$CombatArea/CollisionPolygon2D.look_at(get_global_mouse_position())
	
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
		var tile_obj = tiles_inside_area_details[tiles_inside_area.find(MyTileSet.campfire_off)] # get more details about the tile (tilemap, position)
		interact_signal_objects.append(tile_obj.tilemap.map_to_world(tile_obj.pos))
		if Input.is_action_just_pressed("ui_interact"): # has campfire and "E" pressed
			tile_obj.tilemap.set_cellv(tile_obj.pos, MyTileSet.campfire_lit) # set campfire to lit campfire
			get_parent().get_node("Room/Campfire").emit_signal("play_lit_animation", tile_obj.pos * 32) # set position of campfire light
	
	if MyTileSet.berrybush in tiles_inside_area: # check for berrybushes
		interact_signal += 1 # show "E" interact key
		var tile_obj = tiles_inside_area_details[tiles_inside_area.find(MyTileSet.berrybush)]
		interact_signal_objects.append(tile_obj.tilemap.map_to_world(tile_obj.pos))
		BuschGefunden = true
		BuschTilePos = tile_obj.pos
		BuschObj = tile_obj
	else:
		BuschGefunden = false
	
	for highway in MyTileSet.highway_group: # check for highways
		if highway in tiles_inside_area:
			interact_signal += 1 # show "E" interact key
			var tile_obj = tiles_inside_area_details[tiles_inside_area.find(highway)]
			interact_signal_objects.append(tile_obj.tilemap.map_to_world(tile_obj.pos))
			if Input.is_action_just_pressed("ui_interact"): # has highways and "E" pressed
				if !get_parent().get_node("Room").is_room_locked(): # room unlocked
					var highway_i = MyTileSet.highway_group.find(highway) # get which highway it was left, top, etc
					get_parent().emit_signal("room_update", Helper.direction_group[highway_i]) # update the room to the new one
					position = Helper.direction_spawnpoints[highway_i] * 32 + Vector2(16, 8) # set new Player position
	
	if interact_signal > 0:
		gui.emit_signal("key_popup", "E", interact_signal_objects[0], true) # "E" key popup
	else:
		gui.emit_signal("key_popup", "E", Vector2.ZERO, false)

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


func _on_CombatArea_body_entered(body):
	if !inside_combat_area.has(body) and body != self:
		inside_combat_area.append(body)


func _on_CombatArea_body_exited(body):
	inside_combat_area.remove(inside_combat_area.find(body))

func _on_AttackCooldown_ready():
	can_attack = true
