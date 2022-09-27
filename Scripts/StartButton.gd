extends Button

var last_scene = null
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed(category: String):
	if category == "start":
		last_scene = get_tree().get_current_scene().get_path()
		get_tree().change_scene("res://Scenes/MainGame.tscn")
	elif category == "settings":
		last_scene = get_tree().get_current_scene().get_path()
		get_tree().change_scene("res://Scenes/Settings.tscn")
	elif category == "exit":
		get_tree().quit()
	elif category == "continue":
		get_parent().get_parent().visible = false
	elif category == "back":
		get_tree().change_scene("res://Scenes/MainGame.tscn")


func _on_Start_mouse_entered():
	pass # Replace with function body.
