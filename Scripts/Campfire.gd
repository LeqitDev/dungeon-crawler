extends Node2D

signal play_lit_animation

var init = false;
onready var noise = OpenSimplexNoise.new()
var value = 0.0
const MAX_VALUE = 100000000

func _ready():
	randomize()
	value = randi() % MAX_VALUE
	noise.period = 16

func _physics_process(delta):
	value += 0.5
	if value > MAX_VALUE:
		value = 0.0
	var alpha = ((noise.get_noise_1d(value) + 1) / 4.0) + 0.5
	var color = $Light2D.color
	$Light2D.color = Color(color.r, color.g, color.b, alpha) # change alpha color to random between 0.5 and 1.0 for flicker

func _on_Campfire_play_lit_animation(tile_pos):
	if !init and tile_pos == Vector2.ZERO:
		return
	if !init:
		position = tile_pos + Vector2(16, 16)
		init = true
	$Light2D.enabled = true
	$AnimationPlayer.play("LitCampfireAnimation")
#	$AnimationPlayer.queue("LitIdleCampfireAnimation")
	pass # Replace with function body.
