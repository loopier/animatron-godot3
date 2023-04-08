extends Node

var oscsndr

func _ready():
	
	oscsndr = load("res://addons/gdosc/gdoscsender.gdns").new()
	# [mandatory] will send messages to ip:port

func connectRemote(args):
	var ip = args[0]
	var port = args[1]
	oscsndr.stop()
	oscsndr.setup( ip, port )
	# [mandatory] enabling emission
	oscsndr.start()
	print("connected to %s:%s" % [ip, port])

func send(args):
	# address
	oscsndr.msg(args[0])
	# args
	if len(args) > 1:
		for arg in args.slice(1,-1):
			oscsndr.add(arg)
	# sending the message
	oscsndr.send()
	print("sent OSC message: %s" % [args])

func _exit_tree ( ):
	# disable the sender, highly recommended!
	oscsndr.stop()
