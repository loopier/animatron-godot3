a = Animatron()
MIDIClient.init;
m = MIDIOut(0);
a.sendMsg("/debug", false);
a.sendMsg("/debug", true);
a.sendMsg("/free", "*");

// ------------------------------------------------------------
// basic
// ------------------------------------------------------------
(
a.sendMsg("/load", "numbers");
a.sendMsg("/create", "n", "numbers");
a.sendMsg("/create", "n2", "numbers");
a.sendMsg("/speed", "n", 1/12);
a.sendMsg("/speed", "n2", 1/12);
a.sendMsg("/scale", "n2", 1/2);
a.sendMsg("/position/x", "n2", 1/4);
)
// add/remove MIDI cmds
a.sendMsg("/midi", "noteon", 0, 60, "/frame", "n", 0, 10);
a.sendMsg("/midi", "noteon", 0, 60, "/frame", "n2", 0, 10);
a.sendMsg("/midi/free", "noteon", 0, 60, "/frame", "n");
a.sendMsg("/midi/free", "noteon", 0, 60, "/frame", "n2");
a.sendMsg("/midi/free", "noteon", 0, 60, "/frame", "x2");
a.sendMsg("/midi/free", "noteon", 0, 61, "/frame", "n2");

// test MIDI cmds
a.sendMsg("/midi", "noteon", 0, 60, "/frame", "n", 0, 10);
a.sendMsg("/list/midi");
m.noteOn(0, 60,0);
a.sendMsg("/midi/free", "noteon", 0, 60, "/frame", "n");

// test 2 different MIDI channels
a.sendMsg("/midi", "noteon", 0, 60, "/frame", "n", 0, 10);
a.sendMsg("/midi", "noteon", 1, 60, "/scale", "n", 0.1, 2.0);
a.sendMsg("/midi/list");
m.noteOn(0, 60, 127);m.allNotesOff(0);
m.noteOn(1, 60, 127.rand);m.allNotesOff(1);
a.sendMsg("/midi/free", "noteon", 0, 60, "/frame", "n");
a.sendMsg("/midi/free", "noteon", 1, 60, "/scale", "n");

// ------------------------------------------------------------
// matrix
// ------------------------------------------------------------
(
16.do{|i|
	var n = "n"++(i.mod(16).asInteger);
	a.sendMsg("/create", n, "numbers");
	a.sendMsg("/stop", n);
	a.sendMsg("/scale", n, 0.2);
	a.sendMsg("/frame", n, i);
	a.sendMsg("/position/x", n, (i / 4).linlin(0,4, 0.2,0.8));
	a.sendMsg("/position/y", n, (i.mod(4)).linlin(0,4, 0.2,0.8));
};
a.sendMsg("/midi", "noteon", 0, "*", "/frame", "n0", 0.0, 10.0);
)
(
Tdef(\midi, {
	inf.do{ |i|
		// var ch = 16.rand;
		var ch = 0;
		// var note = 127.rand;
		// var vel = 127.rand;
		var note = 60;
		var vel = 10;
		m.noteOn(ch, note, vel);
		0.1.wait;
		m.noteOff(ch, note, vel);
		1.wait;
	};
}).play;
)
Tdef(\midi).stop;

// ------------------------------------------------------------
// complex
// ------------------------------------------------------------
a.sendMsg("/load", "canon-man");
(
a.sendMsg("/create", "ha", "canon-man");
a.sendMsg("/create", "he", "canon-man");
a.sendMsg("/stop", "h*");
a.sendMsg("/frame", "ha", rrand(50,500));
a.sendMsg("/frame", "he", rrand(50,500));
a.sendMsg("/color", "he", 1,0,0);
a.sendMsg("/position/x", "he", 0.2);
a.sendMsg("/scale", "he", 0.5);
)
a.sendMsg("/midi/debug", false);
a.sendMsg("/new", "sqa", "square");
a.sendMsg("/midi", "noteon", 0, "*", "/rotate", "sqa", 0, 360);

a.sendMsg("/midi/free", "noteon", 0, "*", "/rotate", "sqa");
a.sendMsg("/midi/debug", true);

// all notes on
a.sendMsg("/midi", "noteon", "*", "/frame", "ha", 50,360);
m.noteOn(0, 127.rand, 127.rand.debug);
a.sendMsg("/midi/free", "noteon", "*", "/frame", "ha");
// all notes off
a.sendMsg("/midi", "noteoff", "*", "/frame", "ha", 50,360);
m.noteOn(0, 127.rand, 127.rand.debug);
a.sendMsg("/midi/free", "noteoff", "*", "/frame", "ha");
// all velocity
a.sendMsg("/midi", "velocity", "*", "/scale", "ha", 0.1, 4);
m.noteOn(0, 127.rand, 127.rand.debug);
a.sendMsg("/midi/free", "velocity", "*", "/scale", "ha");
// note on -- using velocity as parameter
a.sendMsg("/midi", "noteon", 60, "/frame", "ha", 50,360);
a.sendMsg("/midi", "noteon", 60, "/scale", "ha", 0.1, 2.0);
m.noteOn(0, 60, 127.rand.debug);
a.sendMsg("/midi/free", "noteon", 60, "/frame", "ha");
a.sendMsg("/midi/free", "noteon", 60, "/scale", "ha");
// note off -- using velocity as parameter
a.sendMsg("/midi", "noteoff", 60, "/frame", "ha", 50,360);
m.noteOff(0, 60, 127.rand.debug);
a.sendMsg("/midi/free", "noteoff", 60, "/frame", "ha");
// cc
a.sendMsg("/midi", "cc", 1, "/frame", "he", 50,360);
m.control(0, 1, 127.rand.debug);
m.noteOn(0, 1, 127.rand.debug);
a.sendMsg("/midi/free", "cc", 1, "/frame", "ha");

a.sendMsg("/stop", "h*");

Ziva.boot;
~m = Pmidi(MIDIOut(0));
(
[
	~m.fast.amp(Pwhite()).midinote(Pwhite(0,127)),
	~m.faster.deg([0,17].pseq),
	~m.deg([0,17].pseq).chan(1),
	~m.faster.deg([0,17].pseq),
	~m.bla([40,60].pseq.linlin(0,127,0.1,1.27).trace),
	nil
].ziva;
)
Pdef(\ziva).remove