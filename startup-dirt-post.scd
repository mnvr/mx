(
var kName = { |k|
	var d = Dictionary['delta' -> "δ", 'orbit' -> "orb", '_id_' -> "id"];
	d[k] ? k;
};

OSCdef(\dirtVis, { |msg|
	var args, argd;
	// The first entry in the message is the OSC address. Rest of them
	// are the args that Tidal passed to us.
	//
	// Example:
	// [ /dirt/play, cps, 0.5625, cycle, 0.0, delta, 1.7777760028839, n, 0.0, s, h ]
	args = msg[1..];
	// The args come in pairs: a key (string) followed by its value (a
	// number or a string). Use the Dictionary.newFrom method to construct
	// a dictionary from these pairs. The as method on Object provides a
	// shortcut for calling Dictionary.newFrom(args).
	argd = args.as(Dictionary);
	argd.keysValuesDo { |k, v|
		"% % ".postf(
			kName.(k),
			if(v.isKindOf(Float).and(k != 'cycle'), {v.asStringPrecF(4)}, {v.asString}));
	};
	"".postln;
}, "/dirt/play");
)

// OSCdef(\dirtVis).free