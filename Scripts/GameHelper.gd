
class_name Helper

const _aspect_ratio = 22 / 14.0
const room_width = 22 # 22 (0..22)
const room_height = 14 # 14 (0..14)

const direction_group = [Vector2.LEFT, Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.DOWN + Vector2.LEFT, Vector2.UP + Vector2.LEFT, Vector2.DOWN + Vector2.RIGHT, Vector2.UP + Vector2.RIGHT]
const direction_spawnpoints = [Vector2(room_width - 1, room_height / 2), Vector2(room_width / 2, room_height - 1), Vector2(1, room_height / 2), Vector2(room_width / 2, 1)]
const direction_player_animation = ["PlayerWalkLeft", "PlayerWalkUp", "PlayerWalkRight", "PlayerWalkDown", "PlayerWalkLeft", "PlayerWalkLeft", "PlayerWalkRight", "PlayerWalkRight"]

static func getTileRatio(aspect_ratio):
	if aspect_ratio == -1:
		aspect_ratio = _aspect_ratio
	print("Possible tile resolutions:")
	for h in range(30):
		var w = h * aspect_ratio
		if w == int(w):
			print(str(w) + " - " + str(h))

static func randomExec(possibility, exec: FuncRef, args: Array):
	var rand = randf()
	if rand < possibility:
		exec.call_funcv(args)

static func randomBool(possibility) -> bool:
	var rand = randf()
	if rand < possibility:
		return true
	else:
		return false
