extends Node2D

var screen_size


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport().size
	var env_size = Vector2(32 * 32, 32 * 19) * 1.5
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
