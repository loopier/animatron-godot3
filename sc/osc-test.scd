(
////////////////////////////////////////////////////////////
// Setup
////////////////////////////////////////////////////////////
"setup.scd".loadRelative.first;
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
	["run", "om-walk-sw", "om-walk-nw", "om-walk-s", "fox-walk", "frog-jump"].do{ |name| n.sendMsg("/load", name) };
	n.sendMsg("/list/anims");
	n.sendMsg("/invalid", "frog");
	n.sendMsg("/free", "*");
	n.sendMsg("/list");
	n.sendMsg("/create", "runner", "run");
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
    march
    run
Status: loaded sequences: [res://animations/run_12fps]
Status: loaded sprites: [res://animations/om-walk-sw.png]
Status: loaded sprites: [res://animations/om-walk-nw.png]
Status: loaded sprites: [res://animations/om-walk-s.png]
Status: loaded sprites: [res://animations/fox-walk_6x1_8fps.png]
Status: loaded sprites: [res://animations/frog-jump_4x2_8fps.png]
Available animations:
	fox-walk
	frog-jump
	om-walk-nw
	om-walk-s
	om-walk-sw
    run
Error: OSC command not found: /invalid
Error: No matches found for: *
Status: Freed: []
Anims: [  ]
Status: Created node 'runner' with 'run'
Status: Created node 'omo' with 'om-walk-sw'
Status: Created node 'oma' with 'om-walk-nw'
Status: selected: [omo, oma]
Status: selected: [oma]
Status: Created node 'omi' with 'om-walk-s'
Status: 'inverted' members: [omo, oma, omi]
Status: 'inverted' members: [omo, oma]
Anims: [ runner, omo, oma, omi ]
Status: Freed: []
Status: Created node 'fox' with 'fox-walk'
Status: Created node 'frog' with 'frog-jump'
Status: 'others' members: [fox, frog]
Anims: [ runner, omo, oma, omi, fox, frog ]
Status: Freed: [fox, frog]
Anims: [ runner, omo, oma, omi ]
*/

// And you should see a slow orange upside-down om at
// the upper-left, a blue om facing you in the
// centre, and a fast black upside-down om at the right.
// They'll have some speech bubbles that last a short while.
)

// If you have a commands/init.osc file installed that defines
// /createsel and /startup, you can run these custom commands
// (like macros).
n.sendMsg("/wait", 2)
n.sendMsg("/startup");
n.sendMsg("/createsel", "frog", "frog-jump")
n.sendMsg("/deselect")

n.sendMsg("/def", "/waitasset", "/wait 1", "/list/assets")
n.sendMsg("/def", "/waitanim", "/wait 2", "/list/anims")
n.sendMsg("/def", "/waitlist", "/waitasset", "/waitanim")
n.sendMsg("/waitasset")
n.sendMsg("/waitlist")

n.sendMsg("/def", "/waitlist", "/wait 2", "/list/assets", "/wait 2", "/list/anims")
n.sendMsg("/waitlist")

n.sendMsg("/def", "/hello", "/list/assets", "/group bob")
n.sendMsg("/hello")
n.sendMsg("/def", "/test arg1 b", "/create $arg1 $b")
n.sendMsg("/test", "fred", "steve")

n.sendMsg("/list/anims")
(
n.sendMsg("/def", "/square actor",
	"/new $actor om-walk-e",
	"/position $actor 0.9 0.25 2",
	"/wait 4",
	"/new $actor om-walk-s",
	"/position $actor 0.8 0.9 2",
	"/wait 3",
	"/new $actor om-walk-w",
	"/position $actor 0.2 0.9 1",
	"/wait 2",
	"/new $actor om-walk-n",
	"/position $actor 0.1 0.25 1")
)
n.sendMsg("/square", "om5")
n.sendMsg("/load/defs", "test.osc")
n.sendMsg("/startup")

n.sendMsg("/list/assets");
n.sendMsg("/load", "march");
n.sendMsg("/create", "m1", "march")
n.sendMsg("/select", "m?")
(1..5).do{|i| n.sendMsg("/position", "m" ++ i, i.linlin(1,5,0,1), 1, 4) }
n.sendMsg("/rotate!", 90, 12)
n.sendMsg("/scale!", "0.25,4", 1)
n.sendMsg("/fade!", 0, 4)

n.sendMsg("/load", "om-jump-up")
n.sendMsg("/load", "pickaxe")
n.sendMsg("/list/anims")
n.sendMsg("/create", "om", "om-jump-up-nw")
n.sendMsg("/create", "axe", "pickaxe")

n.sendMsg("/def", "/go", "/free *", "/create axe pickaxe", "/position axe 0.25 0.5", "/scale axe 2 2")
n.sendMsg("/go") // call repeatedly quickly and check for flicker (fixed tweening with 0 duration)

// If you have a 1024x600 image, you should name it bg-black_1x1_1fps.png
// and can set it as the background (covering the whole view) like this:
n.sendMsg("/load", "bg-black")
n.sendMsg("/create", "bg", "bg-black")
n.sendMsg("/position", "bg", 0.5,0.5)
n.sendMsg("/window/fullscreen", false)
n.sendMsg("/position", "axe", 0.5, 0.5)
n.sendMsg("/position", "om", 0.5, 0.5)
n.sendMsg("/free", "bg")
n.sendMsg("/list")

(
n.sendMsg("/load", "pickaxe");
n.sendMsg("/create", "bigger", "pickaxe");
n.sendMsg("/create", "axe1", "pickaxe");
n.sendMsg("/create", "axe2", "pickaxe");
n.sendMsg("/create", "axe3", "pickaxe");
n.sendMsg("/scale", "bigger", 2, 2);
n.sendMsg("/position", "bigger", 0.4, 1);
n.sendMsg("/position", "axe1", 0.5, 0.5);
n.sendMsg("/position", "axe2", 0.55, 0.55);
n.sendMsg("/position", "axe3", 0.525, 0.6);
n.sendMsg("/color", "axe1", 0.7, 0, 0);
n.sendMsg("/color", "axe2", 0, 0.7, 0);
n.sendMsg("/color", "axe3", 0, 0, 0.7);
)

x.("/list");
x.("/behind bigger axe*");
x.("/behind axe* bigger");
x.("/front bigger axe*");
x.("/front axe* bigger");

x.("/select axe1");
x.("/select axe2");

x.("/behind! axe3");
x.("/front! axe3");
x.("/behind! bigger");
x.("/front! bigger");

(
////////// Wander action
{
	x.("/free *");
	x.("/load pickaxe");
	100.do{ |i|
		var name = "axe" ++ i;
		var scl = i.linexp(0,99,0.1,3);
		x.("/create % pickaxe".format(name));
		x.("/position % % 0.5".format(name, i.linlin(0,99, 0,0.9)));
		x.("/rotate % 360 20".format(name));
		x.("/pivot % 0 1 10".format(name));
		x.("/action % wander 0.2 2".format(name));
		x.("/fade % 0.5".format(name));
		x.("/scale % % %".format(name, scl, scl));
		0.05.wait;
	}
}.forkIfNeeded
)

(
////////// Oscillate action
// "Cartoon walking" character
x.("/free *");
x.("/load cube");
x.("/create cube cube");
x.("/position cube 0.2 0.2");
x.("/action cube oscillate 1 15 0.05 0.1 1 2 0.125");
x.("/position cube 0.8 0.5 4");
)

x.("/load/defs init_example.osc")
x.("/load/defs commands/init_example.osc")
x.("/load/config config_example.osc")
x.("/load/config config/config_example.osc")
x.("/config")
x.("/something")

x.("/list/assets")
x.("/assets/path animations")
x.("/assets/path C:/Users/holag/Documents/Programming/gitreps/animatron/animations")

x.("/load letter-a")
x.("/load letter-b")
x.("/load letter-c")
x.("/list/anims")
x.("/new a letter-a")
x.("/new b letter-b")
x.("/new c letter-c")
x.("/scale", "a", 0.5")
x.("/scale", "b", 0.5")
x.("/position", "a", 0.25, 0.5);
x.("/position", "b", 0.75, 0.5);
x.("/group", "ltrs", "a", "b");
x.("/group", "ltrs", "b");
x.("/group", "ltrs");
x.("/stop", "ltrs");
x.("/play", "ltrs");
x.("/stop", "b");
x.("/list/actors")

(
x.("/new", "n", "numbers");
// x.("/speed", "n", 1/12);
// x.("/play/rand", "n");
// x.("/play/rand", "n", 0);
x.("/stop", "n");
x.("/scale", "n", 0.1, 15);
x.("/scale", "n", 1, 0);
x.("/scale", "n", 1.1, 10);
// x.("/scale", "n", 0.7, 2);
// x.("/scale/xy", "n", 0.2, 0.3, 0.2);
// x.("/scale/x", "n", 0.5, 2.0);
// x.("/scale/y", "n", 0.4, 2.0);
// x.("/position/x", "n", 0.2);
// x.("/position/x", "n", 0.3, 0.7);
// x.("/position/y", "n", 0.2);
// x.("/position/y", "n", 0.7, 0.2);
)