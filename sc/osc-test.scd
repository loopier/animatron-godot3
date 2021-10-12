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
s.boot;
)
(
var test = { |description, msg, waittime=1.0|
	("-- "++description).postln;
	msg.();
	waittime.wait;
};
var create = {
	test.("empty list", {
		n.sendMsg("/list");
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
	test.("wraps fram number", {
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

// syntax for a new test:
// var testname = {
//     test.("a description", {
//     		n.sendMsg(...);
//     		// ...
// 		},
// 		wiattime: defaults-to-1.0);
// };
//
// then add it to the task with:
//
// testname.();
//
// comment to disble tests
t = Task {
	create.();
	transform.();
	walkcycle.();
	transport.();
	2.0.wait;
	free.();
	wildcards.();
	select.();
	1.0.wait;
	group.();
	2.wait;
	wildcardsfree.();
};
t.start;
)