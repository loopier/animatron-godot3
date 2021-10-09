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

n.sendMsg("/create", "runner", "runner-run")
n.sendMsg("/create", "fox", "fox-walk")
n.sendMsg("/create", "om", "om-walk-SW");
n.sendMsg("/create", "oma", "om-walk-SW");
n.sendMsg("/create", "om", "frog-jump")
n.sendMsg("/create", "frog", "frog-jump")

n.sendMsg("/stop", "runner")
n.sendMsg("/play", "runner")
n.sendMsg("/stop", "fox")
n.sendMsg("/play", "fox")
n.sendMsg("/stop", "frog")
n.sendMsg("/play", "frog")
n.sendMsg("/stop", "om")
n.sendMsg("/stop", "oma")
n.sendMsg("/play", "oma")
n.sendMsg("/play", "om")
n.sendMsg("/invalid", "frog")

n.sendMsg("/stop", "@runner@2")
n.sendMsg("/play", "@runner@2")
n.sendMsg("/play", "fox")

n.sendMsg("/list")
n.sendMsg("/free", "*run*")
n.sendMsg("/free", "@fox*")
n.sendMsg("/free", "*g*")
n.sendMsg("/free", "*om*")

n.sendMsg("/free", "*")
n.sendMsg("/list")
