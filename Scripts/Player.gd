extends KinematicBody2D

signal collision

export var speed = 400
var screen_size

var inside_area = []
onready var gui = get_tree().root.get_child(0).get_node("Control/Control")

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
	
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider is TileMap:
			var tilemap = collision.collider as TileMap
			var collision_position = collision.position - collision.normal
			var tile_pos = Vector2(int(collision_position.x / 32), int(collision_position.y / 32))
			var tile_id = tilemap.get_cellv(tile_pos)
	
	if "Campfire" in inside_area:
		gui.emit_signal("key_popup", "E", self.position, true)
	pass


func _on_Player_body_entered(body):
	emit_signal("collision")
	if body is TileMap:
		body.get_cell()
	pass # Replace with function body.


func _on_Area2D_body_entered(body):
	if !inside_area.has(body):
		inside_area.append(body.name)
	pass # Replace with function body.


func _on_Area2D_body_exited(body):
	inside_area.remove(inside_area.find(body.name))
	
	if body.name == "Campfire":
		gui.emit_signal("key_popup", "E", self.position, false)
	pass # Replace with function body.
