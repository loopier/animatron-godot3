extends Action

var oscPeriod := 1.0					# the period of one oscillation in seconds
var oscRotRange : = 0.0					# between +/- this number of degrees
var oscPosRange := Vector2(0.05, 0.05)	# between +/- this (normalized) offset
var oscPosFreq := Vector2(1, 2)			# lissajous normalized frequencies (a, b)
var oscPosPhase := 0.125				# the normalized phase (0-1 == 0-2pi) of the x component


func _init(args : Array):
	if args.size() > 0:
		oscPeriod = float(args[0])
	if args.size() > 1:
		oscRotRange = float(args[1])
	if args.size() > 2:
		oscPosRange = Vector2(float(args[2]), float(args[2]))
	if args.size() > 3:
		oscPosRange.y = float(args[3])
	if args.size() > 4:
		oscPosFreq = Vector2(float(args[4]), float(args[4]))
	if args.size() > 5:
		oscPosFreq.y = float(args[5])
	if args.size() > 6:
		oscPosPhase = float(args[6])


func _physics_process(delta : float):
	var deltaRadians = TAU * delta / oscPeriod
	updateTime(deltaRadians)
	var pos =  Vector2(sin(oscPosFreq.x * curTime + oscPosPhase * TAU), sin(oscPosFreq.y * curTime)) * oscPosRange
	offsetNode.position = pos * OS.window_size.y
	offsetNode.rotation = deg2rad(oscRotRange * sin(curTime))
