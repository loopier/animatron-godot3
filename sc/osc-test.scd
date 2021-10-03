(
// Setup
OSCdef(\listReply, { arg msg;
	"Anims: %".format(msg[1..]).postln;
}, "/list/reply");
OSCdef(\errorReply, { arg msg;
	"Error: %".format(msg[1]).postln;
}, "/error/reply");
OSCdef(\statusReply, { arg msg;
	"Status: %".format(msg[1]).postln;
}, "/status/reply");
n = NetAddr("localhost", 56101);
)

n.sendMsg("/list")

n.sendMsg("/create", "runner")
n.sendMsg("/create", "fox")
n.sendMsg("/create", "frog")

n.sendMsg("/stop", "runner")
n.sendMsg("/play", "runner")
n.sendMsg("/stop", "fox")
n.sendMsg("/play", "fox")
n.sendMsg("/stop", "frog")
n.sendMsg("/play", "frog")
n.sendMsg("/invalid", "frog")

n.sendMsg("/stop", "@runner@2")
n.sendMsg("/play", "@runner@2")
n.sendMsg("/play", "fox")

n.sendMsg("/list")
n.sendMsg("/free", "*run*")
n.sendMsg("/free", "@fox*")
n.sendMsg("/free", "*g*")

n.sendMsg("/free", "*")
n.sendMsg("/list")
