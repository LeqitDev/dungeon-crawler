extends KinematicBody2D

const ACCELERATION = 460
const MAX_SPEED = 225
var velocity = Vector2.ZERO
var item_name

var player = null
var being_picked_up = false

var textures = {
	"Sword": preload("res://Assets/gui/item_icons/sword/sword.png"),
	"SwordII": preload("res://Assets/gui/item_icons/sword/swordII.png"),
	"SwordIII": preload("res://Assets/gui/item_icons/sword/swordIII.png"),
	"SwordIV": preload("res://Assets/gui/item_icons/sword/swordIV.png"),
	"SwordV": preload("res://Assets/gui/item_icons/sword/swordV.png"),
	"Arrow": preload("res://Assets/gui/item_icons/arrow.png"),
	"Redberry": preload("res://Assets/gui/item_icons/redberry.png"),
	"AxeII": preload("res://Assets/gui/item_icons/axeii.png"),
}


signal initItem

# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("initItem", self, "on_init_item")
	if item_name == null:
		item_name = "Redberry"
func _physics_process(delta):
	if being_picked_up == true:
		var direction = global_position.direction_to(player.global_position)
		velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
		
		var distance = global_position.distance_to(player.global_position)
		if distance < 4:
			PlayerInventory.add_item(item_name, 1)
			queue_free()
	velocity = move_and_slide(velocity, Vector2.UP)
	
func pick_up_item(body):
	player = body
	being_picked_up = true
	play_sound()

func play_sound():
	if !$pickupSound.playing:
		$pickupSound.play()

func on_init_item(theitemname):
	item_name = theitemname
	$Sprite.texture = textures[theitemname]
	
