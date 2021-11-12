(
////////////////////////////////////////////////////////////
// Setup
////////////////////////////////////////////////////////////
var separateBySpaces;
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
separateBySpaces = { arg str;
	// This regex isn't perfect, but works
	// reasonably well for most of my cases...
	var regex = '"(.+?)"|(?:([^"]+?)(?=\\s))|(?:(?<=\\s)([^"]+))'.asString;
	var arr = str.asString.findRegexp(regex).flop.last.clump(4).collect{ |x|
		x.drop(1).collect(_.stripWhiteSpace)
	}.flatten.reject(_.isEmpty);
	if (arr.isEmpty) { arr = [ str ] };
	arr
};

x = { arg ...args;
	if (args.notEmpty) {
		var arr = separateBySpaces.(args[0]);
		if (arr.notEmpty) {
			arr = arr ++ args[1..];
			n.sendMsg(*arr);
			arr
		};
	}
};

"Animatron ready.\nUse:\n\tn.sendMsg(\"/load\", \"asset\")\nor:\n\tx.(\"/load asset\")"
)
