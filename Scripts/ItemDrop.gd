extends KinematicBody2D

const ACCELERATION = 460
const MAX_SPEED = 225
var velocity = Vector2.ZERO
var item_name

var player = null
var being_picked_up = false


signal initItem

# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("initItem", self, "on_init_item")
	if item_name == null:
		item_name = "Redberry"
	
	set_particle(item_name)

func _physics_process(delta):
	if being_picked_up == true:
		var direction = global_position.direction_to(player.global_position)
		velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
		
		var distance = global_position.distance_to(player.global_position)
		if distance < 4:
			PlayerInventory.add_item(item_name, 1)
			queue_free()
	velocity = move_and_slide(velocity, Vector2.UP)
	
func pick_up_item(body, posbody):
	player = body
	being_picked_up = true
	play_sound()

func play_sound():
	$pickupSound.play()

func on_init_item(theitemname):
	item_name = theitemname
	$Sprite.texture = PlayerInventory.textures[theitemname]
	set_particle(theitemname)
	

func set_particle(theitemname):
	
	if theitemname == "SwordV":
		$Particles2D.visible = true
		$Particles2D.modulate = Color(1,1,0)
	elif theitemname == "SwordIV":
		$Particles2D.visible = true
		$Particles2D.modulate = Color(1,0,0)
	elif theitemname == "SwordIII":
		$Particles2D.visible = true
		$Particles2D.modulate = Color(0,0,1)
	elif theitemname == "SwordII":
		$Particles2D.visible = true
		$Particles2D.modulate = Color(0,1,0)
