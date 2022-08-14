extends Area2D

var inside_area = false
var is_lit = false
export var cell_size = 32
var collision_box:CollisionShape2D = null

var lit_collision = Vector2(16.02, 12.851)
var lit_transform = Vector2(0, 3.178)

var unlit_collision = Vector2(16.02, 7.156)
var unlit_transform = Vector2(0, 8.873)


# Called when the node enters the scene tree for the first time.
func _ready():
	collision_box = get_child(2).get_child(0) as CollisionShape2D
	var trans = position
	position = Vector2((trans.x - 0.5) * cell_size, (trans.y - 0.5) * cell_size)
	$AnimatedSprite.animation = "unlit"
	$AnimatedSprite.play()
	pass # Replace with function body.

func _process(delta):
	if inside_area and !is_lit:
		if Input.is_action_pressed("ui_interact"):
			$AnimationPlayer/Light2D.enabled = true
			$AnimationPlayer.play("LitCampfireAnimation")
			var rec_shape = RectangleShape2D.new()
			rec_shape.extents = lit_collision
			collision_box.shape = rec_shape
			collision_box.set_transform(Transform2D(0, lit_transform))
			$AnimatedSprite.stop()
			$AnimatedSprite.animation = "lit"
			$AnimatedSprite.play()
			is_lit = true
			$AnimationPlayer.queue("LitIdleCampfireAnimation")
	pass


func _on_Campfire_body_entered(body):
	if body is Node2D:
		if body.name == "Player":
			inside_area = true
	pass # Replace with function body.


func _on_Campfire_body_exited(body):
	if body is Node2D:
		if body.name == "Player":
			inside_area = false
	pass # Replace with function body.
