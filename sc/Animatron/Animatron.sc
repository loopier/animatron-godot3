Animatron {
	var <>osc;
	var <>oscReply;
	var <>config;
	var <>actors;
	var <>assets;

	*new { | addr="localhost", port=56101 |
		^super.new.init(addr, port)
	}

	init { | addr="localhost", port=56101 |
		var separateBySpaces;

		this.osc = NetAddr(addr, port);

		OSCdef(\listActorsReply, { arg msg;
			"Actors: %".format(msg[1..]).postln;
			oscReply = msg.debug("oscdef");
		}, "/list/actors/reply");
		OSCdef(\listAnimsReply, { arg msg;
			"Available animations:\n\t%".format(join(msg[1..], "\n\t")).postln;
		}, "/list/anims/reply");
		OSCdef(\listAssetsReply, { arg msg;
			"Available assets:\n\t%".format(join(msg[1..], "\n\t")).postln;
		}, "/list/assets/reply");
		OSCdef(\errorReply, { arg msg;
			"Error: %".format(msg[1]).postln;
			oscReply = msg;
		}, "/error/reply");
		OSCdef(\statusReply, { arg msg;
			"Status: %".format(msg[1]).postln;
		}, "/status/reply");
		// OSCdef(\oscReply, { arg msg;
		// 	msg.debug("oscreply");
		// }, "/error/reply");

		// n = NetAddr("localhost", 56101);
		// separateBySpaces = { arg str;
		// 	// This regex isn't perfect, but works
		// 	// reasonably well for most of my cases...
		// 	var regex = '"(.+?)"|(?:([^"]+?)(?=\\s))|(?:(?<=\\s)([^"]+))'.asString;
		// 	var arr = str.asString.findRegexp(regex).flop.last.clump(4).collect{ |x|
		// 		x.drop(1).collect(_.stripWhiteSpace)
		// 	}.flatten.reject(_.isEmpty);
		// 	if (arr.isEmpty) { arr = [ str ] };
		// 	arr
		// };

		// x = { arg ...args;
		// 	if (args.notEmpty) {
		// 		var arr = separateBySpaces.(args[0]);
		// 		if (arr.notEmpty) {
		// 			arr = arr ++ args[1..];
		// 			n.sendMsg(*arr);
		// 			arr
		// 		};
		// 	}
		// };

		// "Animatron ready.\nUse:\n\tn.sendMsg(\"/load\", \"asset\")\nor:\n\tx.(\"/load asset\")".postln;

		// x.("/load/config", Platform.userHomeDir++"/work/toplap-20221005-asturies/asturies-config.osc");
		^this.osc;
	}

	// doesNotUnderstand { |selector ...args|
    //     // super.findRespondingMethodFor(selector);

	// }
}