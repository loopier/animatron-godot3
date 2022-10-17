extends Action

var particlesNode : Particles2D
var material : ParticlesMaterial
var particlesAmount : int

func _ready():
	if not particlesNode:
		particlesNode = Particles2D.new()
		material = ParticlesMaterial.new()
		particlesNode.set_process_material(material)
	else:
		actor.remove_child(particlesNode)
	var offset = actor.get_node("Offset")
	var animNode = offset.get_node("Animation")
	particlesNode.set_texture( animNode.frames.get_frame(animNode.animation, animNode.get_frame()))
	particlesNode.amount = particlesAmount
	
	# whichone's best?
#	offset.add_child((particleNode))
	actor.add_child(particlesNode)
#	actor.get_parent().add_child(particleNode)
	
	
	print("name: ", actor.name)
	print("child: ", actor.get_node("Offset/Animation"))
	print("emit: ", particlesNode.emitting)
	print("process mat: ", particlesNode.process_material)
	print("texture: ", particlesNode.texture)
	print("visible: ", particlesNode.visible)
	print("amount: ", particlesNode.amount)
	print("life: ", particlesNode.lifetime)
	print("vel: ", material.initial_velocity)
	print("grav: ", material.gravity)
	
	print("alo: ", actor.get_parent())

func _init(args : Array):
	if args.size() > 0:
		particlesAmount = args[0]

