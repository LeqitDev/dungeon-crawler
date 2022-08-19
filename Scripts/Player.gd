extends KinematicBody2D
signal collision

export var speed = 400
var screen_size


var BuschGefunden = false

var inside_area = []

onready var gui = get_parent().get_node("Control/Control")

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport().size
	$AnimationPlayer.play("LitTorchAnimation")
	$AnimationPlayer.queue("TorchLightAnimations")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var interact_signal = 0
	var fixed_pos = Vector2(position.x, position.y+32)
	
	var pos = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		pos.x += 1
	if Input.is_action_pressed("ui_left"):
		pos.x -= 1
	if Input.is_action_pressed("ui_down"):
		pos.y += 1
	if Input.is_action_pressed("ui_up"):
		pos.y -= 1
	
	#Player Animation 
	
	if pos.x > 0:
		$AnimatedSprite.animation = "right"
		pos = pos.normalized() * speed
		$AnimationPlayer.playback_speed = 2.5
		$AnimatedSprite.play()
		
	elif pos.x < 0:
		$AnimatedSprite.animation = "left"
		pos = pos.normalized() * speed
		$AnimationPlayer.playback_speed = 2.5
		$AnimatedSprite.play()
		
	elif pos.y < 0:
		$AnimatedSprite.animation = "up"
		pos = pos.normalized() * speed
		$AnimationPlayer.playback_speed = 2.5
		$AnimatedSprite.play()
		
	elif pos.y > 0:
		$AnimatedSprite.animation = "down"
		pos = pos.normalized() * speed
		$AnimationPlayer.playback_speed = 2.5
		$AnimatedSprite.play()
		
#	elif pos.length() > 0:
#		$AnimatedSprite.animation = "walk"
#		pos = pos.normalized() * speed
#		$AnimationPlayer.playback_speed = 2.5
#		$AnimatedSprite.play()
	else:
		$AnimationPlayer.playback_speed = 1
		$AnimatedSprite.stop()
		$AnimatedSprite.animation = "idle"
	
	pos = move_and_slide(pos)
	
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider is TileMap:
			var tilemap = collision.collider as TileMap
			var collision_position = collision.position - collision.normal
			var tile_pos = Vector2(int(collision_position.x / 32), int(collision_position.y / 32))
			var tile_id = tilemap.get_cellv(tile_pos)

	if has_area2d_object("GroundWall"):
		var tilemap = get_area2d_object("GroundWall") as TileMap
		
		var highway = -1
		
		for x in range(-1, 2):
			for y in range(-1, 2):
				var tile_pos_wrld = Vector2(fixed_pos.x + x * 32, fixed_pos.y + y * 32)
				
				var tile_pos = tilemap.world_to_map(tile_pos_wrld)
				var tile = tilemap.get_cellv(tile_pos)
				
				highway = MyTileSet.highway_group.find(tile)
				if highway != -1:
					break
			if highway != -1:
				break
		
		if highway != -1:
			interact_signal += 1
			if Input.is_action_just_pressed("ui_interact"):
				get_parent().emit_signal("room_update", Helper.direction_group[highway])
				position = tilemap.map_to_world(Helper.direction_spawnpoints[highway]) + Vector2(16, 8)
	
	if has_area2d_object("CampfireOthers"):
		var tilemap = get_area2d_object("CampfireOthers") as TileMap
		
		for x in range(-1, 2):
			for y in range(-1, 2):
				var tile_pos_wrld = Vector2(fixed_pos.x + x * 32, fixed_pos.y + y * 32)
				
				var tile_pos = tilemap.world_to_map(tile_pos_wrld)
				var tile = tilemap.get_cellv(tile_pos)
				
				if tile == MyTileSet.campfire_off:
					interact_signal += 1
					if Input.is_action_just_pressed("ui_interact"):
						tilemap.set_cellv(tile_pos, MyTileSet.campfire_lit)
						get_parent().get_node("Room/Campfire").emit_signal("play_lit_animation", tilemap.map_to_world(tile_pos))
				
				if tile == MyTileSet.berrybush:
					interact_signal += 1
					BuschGefunden = true
					break
			
			if BuschGefunden == true:
				BuschGefunden = false
				break 
	
	gui.emit_signal("key_popup", "E", self.position, interact_signal > 0)

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
