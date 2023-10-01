/*
  Print short renditions of Dirt events received from Tidal to
  the post window
*/
(
var keyOrder = ['_id_', 'orbit', 'cycle', 'cps', 'delta', 's'];

var orderedKeysValuesDo = { |dict, orderedKeys, f|
	orderedKeys.do { |k|
		var v = dict[k];
		v !? { f.(k, v); dict.removeAt(k) };
	};
	dict.keysValuesDo(f);
};

var print = { |k, v|
	var pk, ps, pv, pn;
	pk = k;
	ps = " ";
	pn = " ";
	switch(k,
		'_id_', { pk = ""; ps = ""; pv = v; pn = '∘' },
		'orbit', { pk = ""; ps = ""; pv = v; },
		'cycle', { var v10 = v % 10;
			pk = 'cyc'; pv = v10.asStringPrecF(if(v10 < 1, 3, 4)).padRight(5)
		},
		'speed', { pv = v.asString },
		'delta', { pk = "δ"; pv = v.asStringPrecF(if(v < 1, if (v < 0.1, 3, 4), 3)).padRight(6); },
		{
			pv =
			if(false.and(v.isKindOf(Float)), {
				v.asStringPrecF(if(v < 1, if (v < 0.1, 3, 4), 3)).padRight(6)
			}, {v.asString})
		}
	);
	"%%%%".postf(pk, ps, pv, pn);
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
	orderedKeysValuesDo.(argd, keyOrder, print);
	"".postln;
}, "/dirt/play");
)

// OSCdef(\dirtVis).free
