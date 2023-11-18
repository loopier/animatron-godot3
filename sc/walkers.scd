(
////////////////////////////////////////////////////////////
// Setup
////////////////////////////////////////////////////////////
"setup.scd".loadRelative.first;
)

x.("/load om-walk-e")

(
x.("/new bg bg-black");
x.("/size bg 2");
x.("/color bg 0.5 0.5 0.5");
x.("/behind bg *");
)

(
~numActors = 20;
~numActors.do{ arg i;
	x.("/create om% om-walk-e".format(i));
	x.("/frame om% %".format(i, 50.rand));
	x.("/position om% % %".format(i, 1.0.rand, rrand(0.2,1)));
	x.("/color om% % % %".format(i, rrand(0, 0.5), rrand(0, 0.5), rrand(0, 0.5)));
};
)

(
n.sendMsg("/def", "/update actor speed size rate",
	"/fade $actor 0 2",
	"/wait 2",
	"/fade $actor 1 2",
	"/speed $actor $speed",
	"/size $actor $size", // add time argument (2) at the end
	"/action $actor wrap 0 $rate 0")
)
x.("/update om5 2 0.5 3")

(
Tdef(\anim, {
	16.do{ arg outer;
		~numActors.do{ arg i;
			var size = exprand(0.5,6) * 1;
			var speed = size.linexp(0.5,8, 2, 0.25) * 1;
			x.("/update om% % % %".format(i, speed, size, speed * size * 0.15));
			exprand(0.2,0.5).wait;
		};
		1.wait;
	};
}).play
)

Tdef(\anim).stop

x.("/list/assets")

x.("/free *")
