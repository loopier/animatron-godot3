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

n.sendMsg("/list/assets")
n.sendMsg("/load/config", "res://config/config.osc");
n.sendMsg("/config");
n.sendMsg("/assets/path"); // report the current path
n.sendMsg("/assets/path", "myanimations/");
n.sendMsg("/assets/path", "animations/");
n.sendMsg("/assets/path", "res://animations/"); // should do same as previous line
n.sendMsg("/window/screen", 1);
n.sendMsg("/window/position", 1500, 200);
n.sendMsg("/window/center"); // works only on display 1 (?)
n.sendMsg("/window/fullscreen", 1);
n.sendMsg("/window/fullscreen", 0);