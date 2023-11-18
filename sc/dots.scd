(
////////////////////////////////////////////////////////////
// Setup
////////////////////////////////////////////////////////////
"setup.scd".loadRelative.first;
)

x.("/load dot-explode")

(
x.("/new bg bg-black");
x.("/size bg 2");
x.("/color bg 0.5 0.5 0.5");
x.("/behind bg *");
)

(
n.sendMsg("/def", "/createDot actor startFrame rate size posx posy",
	"/create $actor dot-explode",
	"/frame $actor $startFrame",
	"/speed $actor $rate",
	"/size $actor $size",
	"/onframe/free $actor 2 /frame $actor",
	"/onframe $actor 2 /frame $actor 0",
	"/position $actor $posx $posy"
);
)

(
~numActors = 30;
~numActors.do{ arg i;
	var t = i * 2pi / ~numActors;
	var posx = cos(t) * 0.4 + 0.5;
	var posy = sin(t) * 0.4 + 0.5;
	var size = i.linexp(0, ~numActors-1, 0.25, 2).debug("size");
	x.("/createDot dot% % % % % %".format(i, 2.rand, rrand(0.75,1.333) * 0.25, size, posx, posy));
};
)

(
n.sendMsg("/def", "/update actor posx posy fadeTime",
	"/position $actor $posx $posy $fadeTime",
);
)
x.("/update dot5 0.2 0.4")

(
Tdef(\anim, {
	inf.do{ arg outer;
		var freq = rrand(0.5, 3);
		var offset = 2pi.rand;
		var fadeTime = rrand(1.0, 3);
		var elapsedTime = 0;
		~numActors.do{ arg i;
			var t = i * 2pi / ~numActors * freq;
			var posx = cos(t + offset) * i.linexp(0, ~numActors-1, 0.02, 0.4) + 0.5;
			var posy = sin(t + offset) * i.linexp(0, ~numActors-1, 0.02, 0.4) + 0.5;
			var size = rrand(0.75,1.333) * 0.25;
			// posx = (1 - posx).wrap(0.25, 0.75);
			// posy = (1 - posy).wrap(0.25, 0.75);
			x.("/update dot% % % % %".format(i, posx, posy, fadeTime));
			elapsedTime = elapsedTime + 0.025;
			0.025.wait;
		};
		(fadeTime - elapsedTime).max(0).wait;
	};
}).play
)

(
~numActors.do{ arg i;
	var startFrame = 0;
	var oldEndFrame = 2;
	var endFrame = 3;
	var actor = "dot" ++ i;
	var numFrames = endFrame - startFrame + 1;
	x.("/frame % %".format(actor, rrand(startFrame, endFrame - 1)));
	x.("/onframe/free % % /frame %".format(actor, oldEndFrame, actor));
	x.("/onframe/free % % /frame %".format(actor, endFrame, actor));
	// x.("/onframe % % /frame % %".format(actor, endFrame, actor, startFrame));
};
)

Tdef(\anim).stop

x.("/list/assets")
x.("/list/anims")
x.("/list")
x.("/free dot*")

