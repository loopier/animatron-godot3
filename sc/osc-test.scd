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

(
Tdef(\a, {
	100.do{|x|
		// "om"++x.postln;
	n.sendMsg("/create", "om"++x, "om-walk-sw");
	n.sendMsg("/speed", "om"++x, rrand(0.7,2.0));
		0.1.wait;
}
}).play
)

(
////////////////////////////////////////////////////////////
// Comprehensive unit tests
////////////////////////////////////////////////////////////
var test = { |description, msg, waittime=0.5|
	("-- " ++ description).postln;
	msg.();
	waittime.wait;
};
var create = {
	test.("empty list", {
		n.sendMsg("/list"); // or /list/actors
	});
	test.("create one instance with animation", {
		n.sendMsg("/create", "omo", "om-walk-SW");
		n.sendMsg("/list");
	});
};
var transform = {
	test.("transform", {
		n.sendMsg("/position", "omo", 0.5, 0.5);
		1.0.wait;
		n.sendMsg("/fliph", "omo");
		1.0.wait;
		n.sendMsg("/fliph", "omo");
		n.sendMsg("/flipv", "omo");
		1.0.wait;
		n.sendMsg("/flipv", "omo");
	});
};
var walkcycle = {
	test.("turn-around test", {
		n.sendMsg("/create", "omo", "om-walk-W");
		1.0.wait;
		n.sendMsg("/create", "omo", "om-walk-NW");
		1.0.wait;
		n.sendMsg("/create", "omo", "om-walk-N");
		1.0.wait;
		n.sendMsg("/create", "omo", "om-walk-NE");
		1.0.wait;
		n.sendMsg("/create", "omo", "om-walk-E");
		1.0.wait;
		n.sendMsg("/create", "omo", "om-walk-SE");
		1.0.wait;
		n.sendMsg("/create", "omo", "om-walk-S");
		1.0.wait;
		n.sendMsg("/create", "omo", "om-to-idle-S");
		1.0.wait;
		n.sendMsg("/create", "omo", "om-to-idle-SW");
		1.0.wait;
		n.sendMsg("/create", "omo", "om-to-idle-SE");
	});
};
var transport = {
	test.("transport", {
		n.sendMsg("/create", "omo", "om-walk-SW");
		n.sendMsg("/stop", "omo");
		1.0.wait;
		n.sendMsg("/play", "omo");
	});
	test.("speed", {
		n.sendMsg("/speed", "omo", 2.0);
		1.0.wait;
		n.sendMsg("/speed", "omo", 0.5);
		1.0.wait;
		n.sendMsg("/speed", "omo", 1.0);
	});
	test.("frame navigation", {
		n.sendMsg("/stop", "omo");
	});
	test.("wraps frame number", {
		n.sendMsg("/frame", "omo", 100);
		1.0.wait;
		n.sendMsg("/frame", "omo", 4);
	});
};
var free = {
	test.("free", {n.sendMsg("/free", "omo", 4);});
};
var wildcards = {
	10.do { |x|
		test.("wildcards",
			{
			n.sendMsg("/create", "om"++x, "om-walk-SW");
			n.sendMsg("/speed", "om"++x, rrand(0.7,2.0));
		}, 0.1);
	};
};
var wildcardsfree = {
	test.("wildcards free", {n.sendMsg("/free", "om*");})
};
var color = {
	test.("change color", {n.sendMsg("/color", "om*", 1,1,1);})
};
var select = {
	test.("none selected", {n.sendMsg("/selected")});
	test.("select one", {
		n.sendMsg("/create", "omo", "om-walk-SW");
		n.sendMsg("/position", "omo", 0.5, 0.5);
		n.sendMsg("/select",  "omo");
		n.sendMsg("/selected");
	});
	test.("select non-existent", {
		n.sendMsg("/select",  "blu");
		n.sendMsg("/selected".postln);
	});
	test.("select with '?'", {
		n.sendMsg("/create", "oma", "om-walk-SE");
		n.sendMsg("/position", "oma", 0.25, 0.5);
		n.sendMsg("/select", "om?");
		n.sendMsg("/selected".postln);
	});
	test.("deselect one", {
		n.sendMsg("/deselect",  "omo");
	});
	test.("list selected", {
		n.sendMsg("/selected".postln);
	});
};
var group = {
	test.("add omo and oma to 'walkers' group", {
		n.sendMsg("/group", "walkers", "om?");
	});
	test.("list group members", {
		n.sendMsg("/group", "walkers");
	});
	test.("remove oma from 'walkers'", {
		n.sendMsg("/ungroup", "walkers", "omo");
	});
	test.("list group members", {
		n.sendMsg("/group", "walkers");
	});
};
var say = {
	test.("say something", {
		n.sendMsg("/create", "omo", "om-idle-SW");
		n.sendMsg("/position", "omo", 0.5, 0.5);
		n.sendMsg("/say", "omo", "something");
		4.wait;
		// n.sendMsg("/say", "omo", "something else\nin two lines");
		n.sendMsg("/say", "omo", "something else in two lines");
		4.wait;
		// n.sendMsg("/say", "omo", "something\nvertical\nin many\nlines");
		n.sendMsg("/say", "omo", "something vertical in many lines");
		4.wait;
		// n.sendMsg("/say", "omo", "something during\na given time", 4);
		n.sendMsg("/say", "omo", "something during a given time", 4);

	})
};
var manysay = {
	test.("many say something",{
		10.do{|x|
			n.sendMsg("/create", "om"++x, "om-idle-"++["SW","S"].choose);
			if(0.5.coin, {n.sendMsg("/fliph", "om"++x)});
			n.sendMsg("/color", "om"++x, 1.0.rand, 0.2.rand, 0.2.rand);
			n.sendMsg("/position", "om"++x, rrand(0.1,0.9), rrand(0.2,0.8));
			rrand(0.2,3.0).wait;
			n.sendMsg("/say", "om"++x, "I'm om"++x, rrand(3,6));
			rrand(0.1,2.0).wait;
		};
	});
};
var listruntimedata = {
	test.("files/assets available to load at runtime", {
		n.sendMsg("/list/assets");
	});
	test.("anims loaded at runtime", {
		n.sendMsg("/list/anims");
	});
};
var loadruntime = {
	test.("load file at runtime", {
		100.do{|x|
			n.sendMsg("/create", "om"++x, "om-idle-"++["e","n","w","s","nw","ne","sw","se"].choose);
			n.sendMsg("/position", "om"++x, rrand(0.1,0.9), rrand(0.2,0.8));
			n.sendMsg("/speed", "om"++x, rrand(0.5,2.0));
			0.1.wait;
		};
	});
};
// syntax for a new test:
// var testname = {
//     test.("a description", {
//     		n.sendMsg(...);
//     		// ...
// 		},
// 		waittime: defaults-to-1.0);
// };
//
// then add it to the task with:
//
// testname.();
//
// comment to disble tests
t = Task {
	// create.();
	// transform.();
	// walkcycle.();
	// transport.();
	// 2.0.wait;
	// free.();
	// wildcards.();
	// color.();
	// select.();
	// 1.0.wait;
	// group.();
	// 2.wait;
	// say.();
	// manysay.();
	listruntimedata.();
	loadruntime.();
	4.wait;
	wildcardsfree.();
};
t.start;
)

n.sendMsg("/list/anims");

(
////////////////////////////////////////////////////////////
// Alternative OSC interface testing (run OSCdef setup first)
////////////////////////////////////////////////////////////
Tdef(\test, {
	n.sendMsg("/list/assets");
	["om-walk-sw", "om-walk-nw", "om-walk-s", "fox-walk", "frog-jump"].do{ |name| n.sendMsg("/load", name) };
	n.sendMsg("/list/anims");
	n.sendMsg("/invalid", "frog");
	n.sendMsg("/free", "*");
	n.sendMsg("/list");
	n.sendMsg("/create", "omo", "om-walk-sw");
	n.sendMsg("/create", "oma", "om-walk-nw");
	n.sendMsg("/select", "om*");
	n.sendMsg("/select");
	n.sendMsg("/deselect", "omo");
	n.sendMsg("/selected");
	n.sendMsg("/stop!");
	n.sendMsg("/stop", "omo");
	n.sendMsg("/frame!", 3);
	n.sendMsg("/frame", "omo", 3);
	n.sendMsg("/play!");
	n.sendMsg("/play", "om?");
	n.sendMsg("/position!", 0.25, 0.25);
	n.sendMsg("/position", "omo", 0.75, 0.5, 2);
	n.sendMsg("/speed!", 0.5);
	n.sendMsg("/speed", "omo", 1.5);
	n.sendMsg("/fliph!");
	n.sendMsg("/fliph", "omo");
	n.sendMsg("/flipv!");
	n.sendMsg("/flipv", "omo");
	n.sendMsg("/create", "omi", "om-walk-s");
	n.sendMsg("/position", "omi", 0.5, 0.5);
	n.sendMsg("/group", "inverted", "om*");
	n.sendMsg("/group", "inverted");
	n.sendMsg("/ungroup", "inverted", "omi");
	n.sendMsg("/group", "inverted");
	n.sendMsg("/color!", 0.8, 0.5, 0);
	n.sendMsg("/color", "omi", 0, 0.5, 0.8);
	n.sendMsg("/deselect", "*");
	n.sendMsg("/list");
	n.sendMsg("/free!");
	n.sendMsg("/create", "fox", "fox-walk");
	n.sendMsg("/create", "frog", "frog-jump");
	n.sendMsg("/group", "others", "f*");
	n.sendMsg("/group", "others");
	n.sendMsg("/speed", "others", 4);
	n.sendMsg("/select", "others");
	n.sendMsg("/list");
	n.sendMsg("/free!");
	n.sendMsg("/list");
	n.sendMsg("/say", "omo", "something");
	n.sendMsg("/say", "omi", "something else", 8);
	n.sendMsg("/select", "oma");
	n.sendMsg("/say!", "I'm oma", 4);
	n.sendMsg("/deselect");
}).play

// The expected output is:
/*
Available assets:
	default
	fox-walk
	...
	om-walk-w
	pickaxe
Status: loaded assets: [res://animations/om-walk-sw.png]
Status: loaded assets: [res://animations/om-walk-nw.png]
Status: loaded assets: [res://animations/om-walk-s.png]
Status: loaded assets: [res://animations/fox-walk_6x1_8fps.png]
Status: loaded assets: [res://animations/frog-jump_4x2_8fps.png]
Available animations:
	fox-walk
	frog-jump
	om-walk-nw
	om-walk-s
	om-walk-sw
Error: OSC command not found: /invalid
Error: No matches found for: *
Status: Freed: []
Anims: [  ]
Status: Created node 'omo' with 'om-walk-sw'
Status: Created node 'oma' with 'om-walk-nw'
Status: selected: [omo, oma]
Status: selected: [oma]
Status: Created node 'omi' with 'om-walk-s'
Status: 'inverted' members: [omo, oma, omi]
Status: 'inverted' members: [omo, oma]
Anims: [ omo, oma, omi ]
Status: Freed: []
Status: Created node 'fox' with 'fox-walk'
Status: Created node 'frog' with 'frog-jump'
Status: 'others' members: [fox, frog]
Anims: [ omo, oma, omi, fox, frog ]
Status: Freed: [fox, frog]
Anims: [ omo, oma, omi ]
*/

// And you should see a slow orange upside-down om at
// the upper-left, a blue om facing you in the
// centre, and a fast black upside-down om at the right.
// They'll have some speech bubbles that last a short while.
)

// If you have a commands/init.csv file installed that defines
// /createsel and /startup, you can run these custom commands
// (like macros).
n.sendMsg("/createsel", "frog", "frog-jump")
n.sendMsg("/startup");
