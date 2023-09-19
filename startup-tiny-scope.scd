// Usage:
//
// To automatically start and show the scope when the server starts,
// add the following to your startup file (after loading this file).
//
//     (Platform.userAppSupportDir +/+ "startup-tiny-scope.scd").load;
//
//     s.doWhenBooted { ~tinyScope.() }
//
(
var colors, tinyScope;

// Save our state in an environment to allow us to reevaluate
// this code block without losing it.
~tinyScopeE = (
	// The buffer written to by the synth and read by the amplitude scope.
	//
	// There can only really be one instance of this buffer before
	// SC starts freaking out (it's apparently a known bug). Also, we share
	// this ScopeBuffer with the default Stethoscope, so if you start seeing
	// error messages and an unresponsive scope, restart SC.
	sb: nil,
	// Because we can have only one buffer, we can have only one window.
	window: nil,
	// The last picked theme color.
	colorIndex: 0,
);

colors = [
	/* Same yellow as the default Stethoscope */
	(bg: Color.black, fg: Color.new255(255, 218, 000)),
	(bg: Color.blue, fg: Color.green),
	(bg: Color.blue, fg: Color.white),
	(bg: Color.white, fg: Color.black),
];

SynthDef(\tinyScope, { |buf|
	ScopeOut2.ar(In.ar(0), buf, 4096, 1024)
}).add;

tinyScope = { |t|
	// Frequency and amplitude scope views.
	var fv, av;
	// A Synth that is used by the amplitude scope.
	var synth;

	var updateColors, sb, window, width, height, px, py, bounds;

	// Handling the Frequency Spectrum view is easy - there is a prebuilt
	// FreqScopeView class. But there is no equivalent StethoscopeView
	// for Stethoscope (how there's a FreqScopeView for FreqScope).
	//
	// So we need to (1) create a buffer, (2) play a synth that writes
	// into that buffer using ScopeOut2, and (3) use that buffer to
	// render our ScopeView.

	// An ordinary buffer doesn't work, it needs to be a ScopeBuffer.
	//
	// And, believe it or not, this needs to be done before we create
	// the FreqScopeView below

	sb = ~sb ?? { ~sb = ScopeBuffer.alloc(s) };

	// 511 is the recommended (minimum?) width
	width = 511 * 5/9;
	height = 240 / if(t.isNil, 1, 2);
	px = Window.screenBounds.width - width;
	// To extend into the Dock area, we need to reset the bounds _after_
	// creating the window. If we pass the bounds as a constructor argument
	// then it gets trimmed to the availableBounds.
	bounds = Rect(px + 4, 0 - 4, width, height);
	window = Window("Scope", bounds).front;
	window.alwaysOnTop = true;
	{ window.bounds = bounds }.defer(2);
	window.layout = VLayout().margins_(0).spacing_(0);

	updateColors = {
		var ci, bgColor, fgColor, sb;

		ci = ~colorIndex;
		bgColor = colors[ci][\bg];
		fgColor = colors[ci][\fg];
		av !? {
			// Wave colors is one for each channel.
			av.waveColors = [fgColor];
			av.background = bgColor;
		};
		fv !? {
			fv.scope.waveColors = [fgColor];
			fv.scope.background = bgColor;
		};
	};

	window.view.mouseDownAction = { |view, x, y, modifiers, buttonNumber, clickCount|
		~tinyScopeE.use {
			// if (buttonNumber == 1) { // right
				window.alwaysOnTop_(window.alwaysOnTop.not);
		// } { // left
				// ~colorIndex = (~colorIndex + 1).mod(colors.size);
				// updateColors.();
		// }
		};
	};

	if (t.isNil.or(t == \amp)) {
		synth = {
			Synth(\tinyScope, [buf: sb],
				target: s.defaultGroup,	addAction: \addAfter)
		};
		// Start the synth now
		synth.value;
		// And restart it after it gets killed by a Cmd-. . We need
		// a bit of delay to get this to work.
		CmdPeriod.add { { synth.value }.defer(0.01) };

		av = ScopeView(window);
		av.fill = false;
		av.bufnum = sb.bufnum;
		av.server = s;
		av.start;
	};

	if (t.isNil.or(t == \freq)) {
		fv = FreqScopeView(window);
		fv.active = true; // We need to turn it on
		fv.freqMode = 1; // Show frequencies on a log scale
	};

	// Remember to clean everything up (except the scope buffer, which
	// we hold on to for next time) when the window is closed.
	window.onClose = {
		av !? { av.stop; synth.free };
		fv !? { fv.kill };
		~window = nil;
	};

	~window = window;

	updateColors.();
};

// Create and show a small window with both an amplitude and freq scope.
//
// Type argument t:
// - \freq - show only amplitude scope
// - \amp  - show only frequency scope
// - nil   - show both
~tinyScope = { |t|
	// If there's an existing window we need to close it first, otherwise
	// we start seeing 'ScopeOut2: Requested scope buffer unavailable!'
	// messages (see the rant about ScopeBuffers above).
	~tinyScopeE.use {
		if (~window.isNil) {
			tinyScope.(t)
		} {
			~window.close;
			{ ~tinyScopeE.use { tinyScope.(t) } }.defer(1);
		}
	};
};
)