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
n.sendMsg("/create", "om", "om-walk-S");
n.sendMsg("/create", "om", "om-walk-SW");
n.sendMsg("/create", "om", "om-to-idle-SW");
n.sendMsg("/create", "om", "om-idle-SW");
n.sendMsg("/create", "om", "om-to-idle-SE");
n.sendMsg("/create", "om", "om-walk-W");
n.sendMsg("/create", "om", "om-walk-NW");
n.sendMsg("/create", "om", "om-walk-N");
n.sendMsg("/create", "om", "om-walk-NE");
n.sendMsg("/create", "om", "om-walk-E");
n.sendMsg("/create", "om", "om-walk-SE");
n.sendMsg("/create", "om", "om-walk-S");
n.sendMsg("/create", "om", "om-walk-SW");
n.sendMsg("/create", "om", "om-walk-W");
n.sendMsg("/create", "oma", "om-walk-SW");
n.sendMsg("/create", "oma", "om-walk-W")
n.sendMsg("/create", "oma", "frog-jump")
n.sendMsg("/create", "frog", "frog-jump")

n.sendMsg("/stop", "runner")
n.sendMsg("/play", "runner")
n.sendMsg("/stop", "fox")
n.sendMsg("/play", "fox")
n.sendMsg("/stop", "frog")
n.sendMsg("/play", "frog")
n.sendMsg("/stop", "om")
n.sendMsg("/play", "om")
n.sendMsg("/stop", "oma")
n.sendMsg("/play", "oma")
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

s.boot;
(
Tdef(\a, {
	100.do{|x|
		// "om"++x.postln;
	n.sendMsg("/create", "om"++x, "om-walk-SW");
	n.sendMsg("/speed", "om"++x, rrand(0.7,2.0));
	// n.sendMsg("/stop", "om"++x);
	// n.sendMsg("/play", "om"++x);
		0.1.wait;
}
}).play
)

n.sendMsg("/create", "omo", "om-walk-SW");
n.sendMsg("/create", "ome", "om-walk-SE");
n.sendMsg("/select", "omo", "ome");
n.sendMsg("/select",  "blu"); // should do nothing
n.sendMsg("/deselect",  "omo");
n.sendMsg("/selected");


n.sendMsg("/create", "omo", "om-walk-SW");
n.sendMsg("/create", "omo", "om-idle-S");
n.sendMsg("/position", "omo", 0.5, 0.5);
n.sendMsg("/speed", "omo", 2.5);
n.sendMsg("/stop", "omo");
n.sendMsg("/frame", "omo", 100);
n.sendMsg("/fliph", "omo");
n.sendMsg("/flipv", "omo");
n.sendMsg("/create", "omo", "om-to-idle-SW");
n.sendMsg("/create", "omo", "om-idle-SW");
n.sendMsg("/play", "omo");
n.sendMsg("/list");
n.sendMsg("/free", "omo");