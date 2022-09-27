extends Camera2D

export var decay = 0.8
export var max_offset = Vector2(100, 75)
export var max_roll = 0.1
export (NodePath) var target

var trauma = 0.0
var trauma_power = 2

var interpolate_val = 3
export var move_val = 40
var camera_target_point = Vector2(736, 480) / 2

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()

func add_trauma(amount):
	trauma = min(trauma + amount, 1.0)
	if trauma > 0.25:
		trauma = 0.25

func _process(delta):
	if target:
		global_position = get_node(target).global_position
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()
	var mid_x = (camera_target_point.x - get_global_mouse_position().x) / move_val
	var mid_y = (camera_target_point.y - get_global_mouse_position().y) / move_val
	mid_x = -6 if mid_x < -6 else mid_x
	mid_x = 6 if mid_x > 6 else mid_x
	mid_y = -6 if mid_y < -6 else mid_y
	mid_y = 6 if mid_y > 6 else mid_y
	var inv = get_tree().root.get_node("/root/MainGame/Control/Control/Inventory")
	var esc = get_tree().root.get_node("/root/MainGame/Control/Control/EscapeMenu")
	if  inv.visible != true and esc.visible != true:
		global_position = global_position.linear_interpolate(-Vector2(mid_x,mid_y), interpolate_val * delta)

func shake():
	var amount = pow(trauma, trauma_power)
	rotation = max_roll * amount * rand_range(-1, 1)
	offset.x = max_offset.x * amount * rand_range(-1, 1)
	offset.y = max_offset.y * amount * rand_range(-1, 1)
