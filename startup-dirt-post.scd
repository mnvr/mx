(
var kName = { |k|
	var d = Dictionary['delta' -> "δ", '_id_' -> "id"];
	d[k] ? k;
};

var print = { |k, v|
	var pk, ps, pv;
	pk = kName.(k);
	ps = " ";
	switch(k,
		'cycle', { var v10 = v % 10;
			pk = 'cyc'; pv = v10.asStringPrecF(if(v10 < 1, 4, 5)).padRight(6)
		},
		'orbit', { pk = 'o'; ps = ""; pv = v; },
		{ pv = if(v.isKindOf(Float), {v.asStringPrecF(4)}, {v.asString}) }
	);
	"%%% ".postf(pk, ps, pv);
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
	argd.keysValuesDo(print);
	"".postln;
}, "/dirt/play");
)

// OSCdef(\dirtVis).free