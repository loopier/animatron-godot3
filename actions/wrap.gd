extends Action

var moveDir := 0.0		# the normalized direction of motion (angle in degrees)
var moveSpeed := 1.0	# the speed of movement
var rotSpeed := 0.0		# the speed of rotation
const margin := 0.1		# extra "safety" zone around the viewport for wrapping


func _init(args : Array):
	if args.size() > 0:
		moveDir = float(args[0])
	if args.size() > 1:
		moveSpeed = float(args[1])
	if args.size() > 2:
		rotSpeed = float(args[2])


func _physics_process(delta : float):
	updateTime(delta)
	var offset = Vector2(moveSpeed, 0).rotated(deg2rad(moveDir)) * delta
	var newPos : Vector2 = actor.position + offset * OS.window_size.y
	actor.rotation_degrees = wrapf(actor.rotation_degrees + rotSpeed * delta, -180, 180)
	var animNode = offsetNode.get_node("Animation")
	var animName = animNode.animation
	var halfSize = animNode.frames.get_frame(animName, 0).get_size() / 2 * actor.scale
	halfSize = halfSize.rotated(deg2rad(actor.rotation_degrees)).abs()
	var animPos : Vector2 = animNode.position * actor.scale;
	animPos = animPos.rotated(deg2rad(actor.rotation_degrees))
	var extra : float = OS.window_size.y * margin

	actor.position = Vector2(
			wrapf(newPos.x,
				-halfSize.x - animPos.x - extra,
				OS.window_size.x + halfSize.x - animPos.x + extra),
			 wrapf(newPos.y,
				-halfSize.y - animPos.y - extra,
				OS.window_size.y + halfSize.y - animPos.y + extra))
