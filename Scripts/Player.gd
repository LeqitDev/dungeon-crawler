extends KinematicBody2D
signal collision

export var speed = 400
var screen_size


var BuschGefunden = false

var inside_area = []
onready var gui = get_tree().root.get_child(0).get_node("Control/Control")
onready var tilemap = get_tree().root.get_child(0).get_node("Room/Enviroment/CampfireOthers")

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport().size
	$AnimationPlayer.play("LitTorchAnimation")
	$AnimationPlayer.queue("TorchLightAnimations")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update()
	
	var pos = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		pos.x += 1
	if Input.is_action_pressed("ui_left"):
		pos.x -= 1
	if Input.is_action_pressed("ui_down"):
		pos.y += 1
	if Input.is_action_pressed("ui_up"):
		pos.y -= 1
	
	if pos.length() > 0:
		$AnimatedSprite.animation = "walk"
		pos = pos.normalized() * speed
		$AnimationPlayer.playback_speed = 2.5
		$AnimatedSprite.play()
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
	
	if has_area2d_object("Campfire"):
		gui.emit_signal("key_popup", "E", self.position, true)
		var hp = gui.get_parent().get_node("HBoxContainer").set_health(5)
		
	if has_area2d_object("CampfireOthers"):
		for x in range(-1,2):
			for y in range(-1,2):
				var fixed_pos = Vector2(position.x, position.y+32)
				var scan_pos = Vector2(fixed_pos.x + x*32, fixed_pos.y + y*32)
				
				var body = get_area2d_object("CampfireOthers")
				
				var tile_pos = body.world_to_map(scan_pos)
				var tile = body.get_cellv(tile_pos)
				if tile == 35:
					print("Busch gefunden")
					gui.emit_signal("key_popup", "E", self.position, true)
					BuschGefunden = true
					break
			if BuschGefunden == true:
				BuschGefunden = false
				break 
				
	pass # Replace with function body.

	


func _on_Area2D_body_entered(body):
	if !inside_area.has(body):
		inside_area.append(body)

func _on_Area2D_body_exited(body):
	inside_area.remove(inside_area.find(body))
	
	if body.name == "Campfire":
		gui.emit_signal("key_popup", "E", self.position, false)
		
	if body.name == "CampfireOthers":
		gui.emit_signal("key_popup", "E", self.position, false)
		
	pass # Replace with function body.
	

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
	
