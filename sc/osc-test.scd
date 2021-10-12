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
n.sendMsg("/select", "runner")
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

n.sendMsg("/list")
n.sendMsg("/free", "*run*")
n.sendMsg("/free", "@fox*")
n.sendMsg("/free", "*g*")
n.sendMsg("/free", "*om*")

n.sendMsg("/free", "*")
n.sendMsg("/list")

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

n.sendMsg("/deselect", "*")
n.sendMsg("/select", "om5*")

n.sendMsg("/create", "omo", "om-walk-SW");
n.sendMsg("/create", "oma", "om-walk-SE");
n.sendMsg("/select", "oma");
n.sendMsg("/select",  "blu"); // should do nothing
n.sendMsg("/select"); // list selected nodes
n.sendMsg("/deselect",  "oma");
n.sendMsg("/selected"); // another way to list selected nodes

n.sendMsg("/group", "walkers", "om?") // add omo and oma to "walkers" group
n.sendMsg("/group", "walkers") // list group members
n.sendMsg("/ungroup", "walkers", "oma") // remove oma from "walkers"
n.sendMsg("/group", "walkers") // list group members

n.sendMsg("/create", "omo", "om-walk-SW");
n.sendMsg("/create", "oma", "om-idle-S");
n.sendMsg("/color");
n.sendMsg("/color", 0.2, 0.5, 0);
n.sendMsg("/position", "omo", 0.5, 0.5);
n.sendMsg("/speed", "om*", 2.5);
n.sendMsg("/stop", "om*");
n.sendMsg("/play", "om*");
n.sendMsg("/frame", "om3?", 100);
n.sendMsg("/fliph", "omo");
n.sendMsg("/flipv", "omo");
n.sendMsg("/create", "omo", "om-to-idle-SW");
n.sendMsg("/create", "omo", "om-idle-SW");
n.sendMsg("/play", "omo");
n.sendMsg("/list");
n.sendMsg("/free", "om*");

(
Tdef(\test, {
	n.sendMsg("/invalid", "frog");
	n.sendMsg("/free", "*");
	n.sendMsg("/list");
	n.sendMsg("/create", "omo", "om-walk-SW");
	n.sendMsg("/create", "oma", "om-walk-NW");
	n.sendMsg("/select", "om*");
	n.sendMsg("/select");
	n.sendMsg("/deselect", "omo");
	n.sendMsg("/selected");
	n.sendMsg("/stop");
	n.sendMsg("/stop", "omo");
	n.sendMsg("/frame", 3);
	n.sendMsg("/frame", "omo", 3);
	n.sendMsg("/play");
	n.sendMsg("/play", "om?");
	n.sendMsg("/position", 0.25, 0.25);
	n.sendMsg("/position", "omo", 0.75, 0.5);
	n.sendMsg("/speed", 0.5);
	n.sendMsg("/speed", "omo", 1.5);
	n.sendMsg("/fliph");
	n.sendMsg("/fliph", "omo");
	n.sendMsg("/flipv");
	n.sendMsg("/flipv", "omo");
	n.sendMsg("/create", "omi", "om-walk-S");
	n.sendMsg("/position", "omi", 0.5, 0.5);
	n.sendMsg("/group", "inverted", "om*");
	n.sendMsg("/group", "inverted");
	n.sendMsg("/ungroup", "inverted", "omi");
	n.sendMsg("/group", "inverted");
	n.sendMsg("/color", 0.8, 0.5, 0);
	n.sendMsg("/color", "omi", 0, 0.5, 0.8);
	n.sendMsg("/deselect", "*");
	n.sendMsg("/list");
	n.sendMsg("/free");
	n.sendMsg("/create", "fox", "fox-walk");
	n.sendMsg("/create", "frog", "frog-jump");
	n.sendMsg("/group", "others", "f*");
	n.sendMsg("/group", "others");
	n.sendMsg("/speed", "others", 4);
	n.sendMsg("/select", "others");
	n.sendMsg("/list");
	n.sendMsg("/free");
	n.sendMsg("/list");
}).play

// The expected output is:
/*
Error: OSC command not found: /invalid
Status: Freed: [omo, oma, omi]
Anims: [  ]
Status: Created node 'omo' width 'om-walk-SW'
Status: Created node 'oma' width 'om-walk-NW'
Status: selected: [omo, oma]
Status: selected: [oma]
Status: Created node 'omi' width 'om-walk-S'
Status: 'inverted' members: [omo, oma, omi]
Status: 'inverted' members: [omo, oma]
Anims: [ omo, oma, omi ]
Status: Freed: []
Status: Created node 'fox' width 'fox-walk'
Status: Created node 'frog' width 'frog-jump'
Status: 'others' members: [fox, frog]
Anims: [ omo, oma, omi, fox, frog ]
Status: Freed: [fox, frog]
Anims: [ omo, oma, omi ]
*/

// And you should see a slow orange upside-down om at
// the upper-left, a blue om facing you in the
// centre, and a fast black upside-down om at the right.
)
