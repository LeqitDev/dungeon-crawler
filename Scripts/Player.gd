extends KinematicBody2D

signal collision

export var speed = 400
var screen_size


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport().size
	$AnimationPlayer.play("LitTorchAnimation")
	$AnimationPlayer.queue("TorchLightAnimations")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
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
	position.x = clamp(position.x, -screen_size.x/2, screen_size.x/2)
	position.y = clamp(position.y, -screen_size.y/2, screen_size.y/2)
	
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider is TileMap:
			var tilemap = collision.collider as TileMap
			var tile_pos = Vector2(int(collision.position.x / 32), int(collision.position.y / 32))
			print(tile_pos)
			var tile_id = tilemap.get_cellv(tile_pos)
			print(tilemap.tile_set.tile_get_name(tile_id))
	pass


func _on_Player_body_entered(body):
	emit_signal("collision")
	if body is TileMap:
		body.get_cell()
	pass # Replace with function body.
