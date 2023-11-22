(
////////////////////////////////////////////////////////////
// Setup
////////////////////////////////////////////////////////////
"setup.scd".loadRelative.first;
)

(
// Create the actor setup commands
// n.sendMsg("/def", "/updown actor holdTime",
// 	"/speed $actor 1",
// 	"/frame $actor 0",
// 	"/noloop $actor",
// 	"/wait $holdTime",
// 	"/speed $actor -1",
// 	"/noloop $actor",
// );
// n.sendMsg("/def", "/make-c actor red green blue offsetx offsety period holdTime",
// 	// "/create $actor cube-unshrink-h",
// 	// "/create $actor cube",
// 	// "/noloop $actor",
// 	"/color $actor $red $green $blue",
// 	"/size $actor 0.5",
// 	"/position $actor $offsetx $offsety",
// 	// "/routine $actor inf $period /updown $actor $holdTime"
// );
n.sendMsg("/def", "/make actor red green blue offsetx offsety",
	"/color $actor $red $green $blue",
	"/size $actor 0.5",
	"/speed $actor 0.5",
	"/position $actor $offsetx $offsety",
);
n.sendMsg("/def", "/make/states actor",
	"/state/add $actor cube cube cube-bubble",
	"/state/add $actor cube-tongue cube-open-eye cube-close",
	"/state/add $actor cube-close cube-open cube-bubble",
	"/state/add $actor cube-bubble cube-open cube-bubble",
	"/state/add $actor cube-open cube-open-eye cube-tongue cube-close",
	"/state/add $actor cube-open-eye cube-close cube-tongue",
	"/state/add $actor cube-shrink-v cube-unshrink-v",
	"/state/add $actor cube-shrink-h cube-unshrink-h",
	"/state/add $actor cube-unshrink-v cube-shrink-v cube-open",
	"/state/add $actor cube-unshrink-h cube-shrink-h cube-bubble",
);
n.sendMsg("/def", "/free/states actor",
	"/state/free $actor cube",
	"/state/free $actor cube-tongue",
	"/state/free $actor cube-close",
	"/state/free $actor cube-bubble",
	"/state/free $actor cube-open",
	"/state/free $actor cube-open-eye",
	"/state/free $actor cube-shrink-v",
	"/state/free $actor cube-shrink-h",
	"/state/free $actor cube-unshrink-v",
	"/state/free $actor cube-unshrink-h",
);
x.("/load cube*");
x.("/load cit-step");
x.("/free *");
~num = 28;
x.("/routine/free/all");
x.("/create/group c cube %".format(~num));
)
(
~num.do{ arg i;
	// x.("/make/states c%".format(i));
	// x.("/free/states c%".format(i));
	// x.("/anim c% cube".format(i));
	// x.("/state/add c% cube cube-open".format(i));
	// x.("/state/add c% cube-bubble cube".format(i));
	if( i%2 == 1, {
		x.("/state/add c% cube cube-bubble".format(i));
		// x.("/state/add c% cube-open cube-open-eye".format(i));
		// x.("/state/add c% cube-open-eye cube-close".format(i));
		// x.("/state/add c% cube-close cube".format(i));
		// x.("/state/add c% cube-bubble cube-shrink-v".format(i));
		// x.("/state/add c% cube-shrink-v cube-unshrink-v".format(i));
		// x.("/state/add c% cube-unshrink-v cube-bubble".format(i));
	});
	if( i%2 == 0, {
		x.("/state/add c% cube cube-open".format(i));
		x.("/state/add c% cube-open cube-close".format(i));
		x.("/state/add c% cube-close cube-open".format(i));
		// x.("/state/add c% cube-bubble cube-open".format(i));
		// x.("/state/add c% cube-open cube-tongue".format(i));
		// x.("/state/add c% cube-tongue cube-close".format(i));
		// x.("/state/add c% cube-close cube".format(i));
		// x.("/state/add c% cube-shrink-h cube-unshrink-h".format(i));
		// x.("/state/add c% cube-unshrink-h cube-bubble".format(i));
	});
	x.("/free/states c%".format(i));
	x.("/anim c% cube".format(i));
};
)

(
// Algorithmically create and animate a bunch of cubes
~num.do{ arg i;
	var row = (i % 4) - 1;
	var col = 1 - (i div: 4 - 1);
	var posx = 0.12 * col + 0.5;
	var posy = 0.25 * row + 0.5 + (0.105 * col);
	var rgb = rrand(-0.3, 0.3 ! 3);
	// var rgb = col mod: 2 / 2 ! 3 * [1,1,-1];
	// Try different modulus, from 2 to ~num
	// var period = (i % ~num).linexp(0, ~num-1, 0.5, 8);
	// x.("/make-c c% % % % % % % %".format(i, rgb[0], rgb[1], rgb[2], posx, posy, period, period / 2).debug("cmd"));
	x.("/make c% % % % % %".format(i, rgb[0], rgb[1], rgb[2], posx, posy).debug("cmd"));
}
)


x.("/list/routines")
x.("/free *")
x.("/free/states")
x.("/speed * 0.75")
x.("/list/states c0")
x.("/list/anims")
x.("/list/assets")
x.("/list")
x.("/load cit")
x.("/action c* wander 0.2 0.5")
x.("/rotate c* 90 1")
{ ~num.do{ arg i; x.("/size c% 0.5 0".format(i)); 0.0625.wait; } }.fork
{ ~num.do{ arg i; x.("/rotate c% 90 0".format(i)); 0.25.wait; } }.fork
{ ~num.do{ arg i; x.("/fade c% 0 8".format(i)); 0.25.wait; } }.fork
)

x.("/flipv c7")
x.("/state/add c7 cube-bubble cube-bubble cit")
x.("/state/add c7 cit cube-shrink-v cube-bubble")



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
x.("/make/states c7")

x.("/load cube-*")
x.("/free *")
x.("/create c cube-open-eye")
x.("/make/states c")
x.("/speed c 0.5")
x.("/stop c")
x.("/frame c 10")
x.("/anim c cube-open-eye");
x.("/stop c");
x.("/state/add c cube-open-eye cube-tongue")
x.("/state/add c cube-tongue cube-open-eye cube-tongue")
x.("/state/add c cube-open cube-close cube-open-eye")
x.("/state/add c cube-open-eye cube-close")
x.("/state/add c cube-close cube-open")
x.("/state/add c cube cube-shrink-h cube-shrink-v cube-bubble")
x.("/state/add c cube-shrink-h cube-unshrink-h")
x.("/state/add c cube-shrink-v cube-unshrink-v")
x.("/state/add c cube-unshrink-v cube-shrink-v cube-shrink-h cube-bubble")
x.("/state/add c cube-unshrink-h cube-shrink-h cube-shrink-v cube-bubble")
x.("/state/add c cube-bubble cube-shrink-v cube-shrink-h")
x.("/list/assets")
x.("/color c 0.2 0.1 0")