(
a = Animatron()
s.waitForBoot{
	Pdef(\a, Pbind()).play;
}
)

a.sendMsg("/debug", true);
a.sendMsg("/debug", false);
a.sendMsg("/load", "circle");
a.sendMsg("/load", "canon-man");
a.sendMsg("/list/assets");
a.sendMsg("/free", "*");
(
a.sendMsg("/new", "ca", "circle");
a.sendMsg("/new", "mac", "canon-man");
// a.sendMsg("/color", "mac", 1,1,1);
a.sendMsg("/frame", "mac", 300);
a.sendMsg("/stop", "mac");
a.sendMsg("/sound", 1, "/scale", "ca", 0.0,1.0);
a.sendMsg("/sound", 1, "/frame", "mac", 300.0,400.0);
)
a.sendMsg("/sound/free", 1, "/scale", "ca");
a.sendMsg("/sound", 1, "/scale", "ca", 0.0,1.0);
a.sendMsg("/sound/free", 1, "/frame", "mac");
a.sendMsg("/sound/free", 1);
