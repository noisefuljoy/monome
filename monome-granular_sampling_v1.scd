Server.default.makeGui

(
Server.default = Server.local;


SynthDef(\bufamp, {|out=0 bufnum amp=0.5 pan=0 modrate=1 relBus posBus rate gate=1|
	var env, sig, rel, pos;
	rel = In.kr(relBus, 1);
	//rate = In.kr(rateBus, 1);
	pos = In.kr(posBus, 1);
	env = EnvGen.ar(Env.perc(0.001,rel),gate, doneAction: 2);
	//sig = BufRd.ar(1, bufnum, SinOsc.ar(modrate) * BufFrames.ir(bufnum), 1);
	sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*rate,1, pos *BufFrames.kr(bufnum), loop: 1);
	Out.ar(out, Pan2.ar(sig*env*amp, LFNoise0.kr(3.2).range(-0.6,0.7) )); }).add;

~relBus = Bus.control(s, 1).set(2);
~posBus = Bus.control(s, 1).set(0);
~rateBus = Bus.control(s, 1).set(1);
~seq_intBus = Bus.control(s, 1).set(0.125);

~releaseVar = 2;
~samSelect = 0;
~scale = Scale.minorPentatonic(\pythagorean);

~toneCollection = [ 0.5, 0.5925925925922, 0.6666666666659, 0.7499999999988, 0.88888888888685, 1.0, 1.1851851851844, 1.3333333333318, 1.4999999999976, 1.7777777777737,
	2.0, 2.3703703703688, 2.6666666666636, 2.9999999999952, 3.5555555555474, 4];


~m = MonomeGrid.new();

s.waitForBoot({

	var draw, seq, cols = 16, rows = 8;


	~zith_paths = "/home/numina/samples/*.wav".pathMatch;
	//~type_paths = "/media/numina/Datapanic/Dropbox/ARCHIVAL_consciousness/typewriter_samples/*.wav".pathMatch;

	~zith_samples = ~zith_paths.collect{|i| Buffer.read(s, i); };
	//~type_samples = ~type_paths.collect{|i| Buffer.read(s, i); };


	MonomeGrid.setAddCallback({
	 arg serial, port, prefix;
	("gridje is er : " ++ serial ++ " " ++ port ++ " " ++ prefix).postln;
	if ( serial == MonomeGrid.getConnectedDevices[0], {
		cols = ~m.cols;
		rows = ~m.rows;
	});
});

	~relSpec = [ 0.05,6.0, \exp,0.01].asSpec;
	~seq_int_spec = [ 0.0075, 0.5, \exp, 0.01].asSpec;
	~posSpec = [ 0.0, 0.9, \linear, 0.001].asSpec;


	~m.connect(0); // 0 (or not supplying any argument) means the first-connected device
    ~step = Array.fill(~m.cols * ~m.rows, { 0 } );
	~synth_arr = Array.fill(~m.cols * ~m.rows, { nil });
	~play_pos = -1;


	~lastCol = cols - 1;
	~lastRow = rows - 1;

	~clock = TempoClock.new(1);
	~seq_int = 0.125;

	~tempoBus = Bus.control(s, 1).set(1);

	~tempo = 1;

	{ Out.kr(~tempoBus, LFNoise0.kr(3.2).range(0.01, 13)); }.play;

	~tempoRoutine = Routine({inf.do{
		~tempoBus.get{|i| ~tempo = i; };
		//~tempo.postln;
		~clock.tempo_(~tempo);
		0.1.wait; }; }).play;

	//~clock.tempo_(LFNoise0.kr(3.2).range(0.9, 4.8));


	~m.key({| x y z |
		[x, y, z].postln;
		if ((z == 1) && (y <= (~lastRow)), {
			var pos = x + (y * 16);
			if (~step[pos] == 1,
				{ ~step[pos] = 0;

				if ( ~synth_arr[pos] != nil, {

					/*		~synth_arr[pos].set(\gate, 0);
						("synth nr " ++ ~synth_arr[pos] ++ " off ").postln;
							~synth_arr.put(pos, nil);
						*/
					});

				},
				{ ~step[pos] = 1 });
		});

			 });





	seq = Routine({

		    loop {

			~play_pos = ( ~play_pos + 1 ).wrap(0, ~lastCol);

			for(0, ~lastRow, {arg t;

				if (~step[(t*16) + ~play_pos] == 1,

					{
						"press".postln;

							~synth_arr.put( (t*16) + ~play_pos,
							Synth(\bufamp,[\bufnum, ~zith_samples[~samSelect],
									\pan, -0.8,
									\amp, 0.5,
								     \rate, ~toneCollection[t*2],
									\relBus, ~relBus.index,
                                    \posBus, ~posBus.index
						]); );





				});



			draw.value;
			~seq_int.yield;

			});
		};
			});



	draw = {
		var highlight;

		for(0, ~lastCol, {arg x;
			if(x == ~play_pos,
				{highlight = 6},
				{highlight = 0});

			for(0, ~lastRow, {arg y;
				~m.led(x, y, (~step[y*16+x] * 11) + (highlight));
			});

		});

		for(0, ~lastRow, {arg t;

				if(~step[(t*16) + ~play_pos ] == 1,
					{~m.led(t, ~lastRow-1, 15); }
				);
			});


	};

	seq.play(~clock);

});

MIDIIn.connectAll;

MIDIdef.cc(\nanoKontrol, {|val num chan src|
	[num, val, chan, src].postln;

	case
	{ num == 56 } {       ~seq_int = ~seq_int_spec.map(val/127);  }
	{ num == 57 } {       ~posBus.set(~posSpec.map(val/127)); }
	{ num == 58 } {       ~relBus.set(~relSpec.map(val/127)); }
	{ num == 40 } { if ( ~samSelect != 7, { ~samSelect = ~samSelect + 1; }, { ~samSelect = 0; });

	};


}, nil);




)


~m.cleanup


MonomeGrid
