(
////////////////////////////////////////////////////////////
// Setup
////////////////////////////////////////////////////////////
"setup.scd".loadRelative.first;
)

(
// Create the actor setup commands
n.sendMsg("/def", "/updown actor holdTime",
	"/noloop $actor",
	"/speed $actor 1",
	"/frame $actor 0",
	"/play $actor",
	"/wait $holdTime",
	"/stop $actor",
	"/speed $actor -1",
	"/loop $actor",
	"/once $actor"
);
n.sendMsg("/def", "/make-c actor red green blue offsetx offsety period holdTime",
	"/create $actor cube-unshrink-h",
	"/noloop $actor",
	"/color $actor $red $green $blue",
	"/size $actor 0.5",
	"/position $actor $offsetx $offsety",
	"/routine $actor inf $period /updown $actor $holdTime"
);
x.("/load cube-unshrink-h");
)

(
// Algorithmically created a bunch of cubes
var num = 15;
x.("/routine/free/all");
x.("/free *");
num.do{ arg i;
	var rgb = rrand(-0.3, 0.3 ! 3);
	var row = (i % 3) - 1;
	var col = 1 - (i div: 3 - 1);
	var posx = 0.12 * col + 0.5;
	var posy = 0.25 * row + 0.5 + (0.105 * col);
	// Try different modulus, from 2 to num
	var period = (i % 4).linexp(0, num-1, 0.5, 8);
	x.("/make-c c% % % % % % % %".format(i, rgb[0], rgb[1], rgb[2], posx, posy, period, period / 2).debug("cmd"));
}
)



x.("/action c* wander 0.2 0.5")






(
// An explicit version
n.sendMsg("/def", "/make-cubes",
	"/make-c c1 0.2 0.2 0.2 0.62 0.355 12 6",
	"/make-c c2 -0.2 -0.2 -0.2 0.62 0.605 6 3",
	"/make-c c3 0.0 0.0 0.0 0.62 0.855 4 2",
	"/make-c c4 0.2 -0.2 -0.2 0.5 0.25 3 2",
	"/make-c c5 -0.2 0.2 -0.2 0.5 0.5 2 1",
	"/make-c c6 0.2 0.2 -0.2 0.5 0.75 1 0.5",
	"/make-c c7 -0.2 -0.2 0.2 0.38 0.145 0.666667 0.3333",
	"/make-c c8 0.2 -0.2 0.2 0.38 0.395 0.5 0.25",
	"/make-c c9 -0.2 0.2 0.2 0.38 0.645 0.333333 0.1666667"
);
)

x.("/make-cubes")
