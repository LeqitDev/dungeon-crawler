## Inheritance

extends KinematicBody2D


## Signals

signal combat(player_pos, dmg)
signal die

## Variables

var health = 10
export var speed = 60

var knockback: Vector2

onready var player: KinematicBody2D = get_tree().root.get_node("MainGame/Player")
onready var config = Helper.getConfig(self)

export var num_rays = 32
export var view_distance = 50
var additional_rotation = 0
var counter = 0

var ray_directions = []
var interest = []
var danger = []

var debug = false
var debug_draw = {}

var home_position = Vector2.ZERO

var state = State.IDLE
var attack_state = AttackState.IDLE

var chosen_dir = Vector2.ZERO

onready var attack_cooldown = $Timer
var can_attack = false

var rand = randf()


## Constants


## Enums

enum State {IDLE,CHASE,ATTACK}
enum AttackState {IDLE,START,ATTACK,END,ROTATE}


## Functions

### Functions/Built-In

# Called when the node enters the scene tree for the first time.
func _ready():
	view_distance = speed
	
	home_position = position # for State.IDLE
	
	interest.resize(num_rays)
	danger.resize(num_rays)
	ray_directions.resize(num_rays)
	for i in num_rays:
		var angle = i * 2 * PI / num_rays
		ray_directions[i] = Vector2.LEFT.rotated(angle)
		interest[i] = 0.0
	
	attack_cooldown.start(5) # begin with attack cooldown
	attack_cooldown.one_shot = true

func _process(delta):
	debug = get_debug()
	
	update()
	
	var distance_to_player = position.distance_to(player.position)
	var vector_to_player = _get_vector_to_player()
	
	var pos: Vector2 = Vector2.ZERO
	
	var safe_range = 70 # min range from player
	var middle_range = safe_range + 25 # best range from player
	var chase_range = safe_range + 50 # max range from player
	
	match state:
		State.IDLE:
			# walk around but dont go to far from home_position
			continue
		State.CHASE:
			set_interest(_get_vector_to_player())
			set_danger()
			
			choose_direction()
			
			
			if distance_to_player > middle_range:
				pos += chosen_dir
			else: # if near the player: try to attack him
				_change_state(State.ATTACK)
				pos -= chosen_dir
		State.ATTACK:
			# charge attack go back
			var attack_range = 25
			var cur_range = 0
			
			var interest = player.position - position
			
			if distance_to_player < attack_range: # go through attack states
				if _is_attack_state(AttackState.ROTATE):
					continue
				if _is_attack_state(AttackState.START):
					_change_attack_state(AttackState.ATTACK)
				if _is_attack_state(AttackState.ATTACK):
					_change_attack_state(AttackState.END)
			
			
			match attack_state:
				AttackState.IDLE:
					additional_rotation = deg2rad(0)
					cur_range = middle_range
					
				AttackState.START:
					additional_rotation = deg2rad(0)
					cur_range = attack_range
					
				AttackState.ATTACK:
					additional_rotation = deg2rad(0)
					
				AttackState.END:
					attack_cooldown.start(5)
					can_attack = false
					cur_range = middle_range # go back to middle range
					
					if distance_to_player >= middle_range: # after attack rotate around player
						additional_rotation = deg2rad(90 if randf() <= .5 else -90)
#
						_change_attack_state(AttackState.ROTATE)
					
				AttackState.ROTATE:
					interest = player.position - position
					cur_range = safe_range
					
					counter += delta
					
					# random rotation or still standing
					if additional_rotation == 360:
						interest = Vector2.ZERO
					if counter >= 0.5:
						if randf() <= 0.25:
							if additional_rotation != 360 or additional_rotation != 0:
								if randf() <= 0.25:
									additional_rotation = 360
								else:
									additional_rotation *= -1
							else:
								additional_rotation = deg2rad(90 if randf() <= .5 else -90)
						counter = 0
			
			# backing off if near the player
			if distance_to_player < safe_range and _is_attack_state(AttackState.ROTATE):
				interest = player.position - position
				_change_attack_state(AttackState.IDLE)
			
			# end the backing off
			if distance_to_player >= middle_range and _is_attack_state(AttackState.IDLE):
				additional_rotation = deg2rad(90 if randf() <= .5 else -90)
				_change_attack_state(AttackState.ROTATE)
			
			debug_draw["interest"] = interest
			set_interest(interest.normalized(), additional_rotation) # get interests with rotations
			set_danger() # get dangers
			
			choose_direction()
			
			if distance_to_player <= attack_range: # reset attack
				attack_cooldown.start(5)
				can_attack = false
			if distance_to_player >= chase_range: # player too far away follow him
				_change_state(State.CHASE)
			else:
				if distance_to_player > cur_range: # if enemy can come closer do it
					pos += chosen_dir
				else: # enemy to close go away
					pos -= chosen_dir

	# handle knockback
	pos += knockback
	knockback = knockback.linear_interpolate(Vector2.ZERO, 0.025)

	pos = pos.normalized() * speed

	pos = move_and_slide(pos)

func _draw():
	if !debug:
		return
	draw_line(Vector2.ZERO, player.position - position, Color(0, 255, 0), 3)
	for i in num_rays:
		draw_line(Vector2.ZERO, ray_directions[i] * view_distance * interest[i], Color(255, 0, 0), 1)
	draw_line(Vector2.ZERO, chosen_dir * view_distance, Color(0, 0, 255), 2)
	
	if debug_draw.has("interest"):
		draw_circle(debug_draw["interest"], 10, Color(100, 100, 100))
	if debug_draw.has("enemy_angle"):
		draw_circle(debug_draw["enemy_angle"], 20, Color(0, 0, 0))


### Functions/Others

func set_interest(point_of_interest: Vector2, additional_rotation = 0):
	for i in num_rays:
		var d = ray_directions[i].rotated(rotation + additional_rotation).dot(point_of_interest)
		interest[i] = max(0, d)

func set_danger():
	var space_state = get_world_2d().direct_space_state
	for i in num_rays:
		var result = space_state.intersect_ray(position, position + ray_directions[i].rotated(rotation) * view_distance, [self])
		if result:
			if result.collider.name == "Layer1" or result.collider.name == "Layer2" or result.collider.name.find("Enemy") != -1:
				danger[i] = clamp((position.distance_to(result.position) / (view_distance * clamp(interest[i], 0.001, 1.0))) - 1, -1.0, 0.0) # steer away if danger high (distance)
			elif result.collider.name == "Layer0":
				danger[i] = -5.0 # hide the interest see below
			else:
				danger[i] = 0.0
		else:
			danger[i] = 0.0

func choose_direction():
	for i in num_rays:
		if danger[i] != 0.0:
			interest[i] = danger[i] # set interest to danger
		if danger[i] == -5.0:
			interest[i] = 0 # remove interest
	
	chosen_dir = Vector2.ZERO
	for i in num_rays:
		chosen_dir += ray_directions[i] * interest[i]
	chosen_dir = chosen_dir.normalized()

func update_health(amount):
	health += amount # change health
	if health <= 0:
		emit_signal("die")
		queue_free() # enemy dies

func _get_vector_to_player() -> Vector2:
	return position.direction_to(player.position)

func _is_state(state) -> bool:
	return self.state == state

func _is_attack_state(state) -> bool:
	return self.attack_state == state

func _change_state(state) -> void:
	self.state = state
	
	# debug output
	if debug:
		print("State." + State.keys()[state])

func _change_attack_state(state) -> void:
	self.attack_state = state
	
	# debug output
	if debug:
		print("AttackState." + AttackState.keys()[state])

func get_debug() -> bool:
	var dbg = config.getProp("debug")
	if !dbg:
		return false
	return dbg


## Signal functions

func _on_Node2D_combat(player_pos: Vector2, dmg: int, crit: float = 0.0):
	knockback = -_get_vector_to_player() * 3
	update_health(-dmg)
	Helper.randomExec(crit, funcref(self, "update_health"), [-dmg]) # random +1 (crit or smth like that)
	get_tree().root.get_node("MainGame/ShakeCamera2D").add_trauma(0.2) # shake camera
	
	if _is_state(State.ATTACK):
		_change_state(State.CHASE)
	elif _is_state(State.IDLE):
		_change_state(State.CHASE)

func _on_Timer_timeout():
	_change_attack_state(AttackState.START)
	can_attack = true


## Inner classes


## Constructor
