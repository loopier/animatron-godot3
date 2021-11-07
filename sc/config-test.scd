(
////////////////////////////////////////////////////////////
// Setup
////////////////////////////////////////////////////////////
OSCdef(\listActorsReply, { arg msg;
	"Actors: %".format(msg[1..]).postln;
}, "/list/actors/reply");
OSCdef(\listAnimsReply, { arg msg;
	"Available animations:\n\t%".format(join(msg[1..], "\n\t")).postln;
}, "/list/anims/reply");
OSCdef(\listAssetsReply, { arg msg;
	"Available assets:\n\t%".format(join(msg[1..], "\n\t")).postln;
}, "/list/assets/reply");
OSCdef(\errorReply, { arg msg;
	"Error: %".format(msg[1]).postln;
}, "/error/reply");
OSCdef(\statusReply, { arg msg;
	"Status: %".format(msg[1]).postln;
}, "/status/reply");
n = NetAddr("localhost", 56101);
)

n.sendMsg("/load/config", "config.osc");
n.sendMsg("/window/screen", 1);
n.sendMsg("/window/pos", 2100, 200);
n.sendMsg("/window/center");