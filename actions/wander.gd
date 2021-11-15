extends Action

var noise := OpenSimplexNoise.new()
var wanderRange : float = 0.1		# as a fraction of the screen
var wanderSpeed : float = 1

func _init(args : Array):
	if args.size() > 0:
		wanderRange = float(args[0])
	if args.size() > 1:
		wanderSpeed = float(args[1])
	noise.seed = randi()
	noise.octaves = 2
	noise.period = 4.0
	noise.persistence = 0.5
	noise.lacunarity = 2


func _physics_process(delta : float):
	updateTime(delta * wanderSpeed)
	var pos = Vector2(noise.get_noise_1d(curTime), 0)
	pos = pos.rotated(PI * noise.get_noise_2d(-5.37, curTime))
	offsetNode.position = pos * wanderRange * OS.window_size.y
