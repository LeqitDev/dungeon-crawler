extends HBoxContainer

var heart_full = preload("res://Assets/gui/hearts/heart-full.png")
var heart_half = preload("res://Assets/gui/hearts/heart-half.png")
var heart_empty = preload("res://Assets/gui/hearts/heart-empty.png")


func update_health(value):
	for i in get_child_count():
		if value > i * 2 + 1:
			get_child(i).texture = heart_full
		elif value > i * 2:
			get_child(i).texture = heart_half
		else:
			get_child(i).texture = heart_empty

func get_health():
	var health = 0;
	for i in get_child_count():
		if get_child(i).texture == heart_full:
			health += 2
		elif get_child(i).texture == heart_half:
			health += 1
		elif get_child(i).texture == heart_empty:
			health += 0
	return health;
	
func damage_health(value):
	update_health(get_health()-value)
