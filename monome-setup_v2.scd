Server.default.makeGui

thisProcess.platform.recordingsDir = "/home/numina/Music";

thisProcess.platform.recordingsDir
(

Server.default = Server.local;


SynthDef(\bufamp, {|out=0 bufnum amp=0.5 pan=0 modrate=1 relBus posBus rateBus gate=1|
	var env, sig, rel, rate, pos;
	rel = In.kr(relBus, 1);
	rate = In.kr(rateBus, 1);
	pos = In.kr(posBus, 1);
	env = EnvGen.ar(Env.perc(0.001,rel),gate, doneAction: 2);
	//sig = BufRd.ar(1, bufnum, SinOsc.ar(modrate) * BufFrames.ir(bufnum), 1);
	sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*rate,1, pos *BufFrames.kr(bufnum), loop: 1);
	Out.ar(out, Pan2.ar(sig*env*amp, pan )); }).add;

~relBus = Bus.control(s, 1).set(2);
~posBus = Bus.control(s, 1).set(0);
~rateBus = Bus.control(s, 1).set(1);
~seq_intBus = Bus.control(s, 1).set(0.125);

~releaseVar = 2;

~scale = Scale.partch_o1(\partch);

~oton =
Array.fill(128, {|i|

	var sc = ~scale, octave = i / 5;
	case
	{ octave < 1; } { sc.semitones.wrapAt(i) }
	{ ((octave == 1) or: (octave > 1)) and: (octave < 2) } { sc.semitones.wrapAt(i) + 1 }
	{ ((octave == 2) or: (octave > 2)) and: (octave < 3)  } { sc.semitones.wrapAt(i) + 2 }
	{ ((octave == 3) or: (octave > 3)) and: (octave < 4)  } { sc.semitones.wrapAt(i) + 12 }
	{ ((octave == 4) or: (octave > 4)) and: (octave < 5)  } { sc.semitones.wrapAt(i) + 13 }
	{ ((octave == 5) or: (octave > 5)) and: (octave < 6)  } { sc.semitones.wrapAt(i) + 14 }
	{ ((octave == 6) or: (octave > 6)) and: (octave < 7)  } { sc.semitones.wrapAt(i) + 24 }
	{ ((octave == 7) or: (octave > 7)) and: (octave < 8)  } { sc.semitones.wrapAt(i) + 25 }
	{ ((octave == 8) or: (octave > 8)) and: (octave < 9)  } { sc.semitones.wrapAt(i) + 26 }
	{ ((octave == 9) or: (octave > 9)) and: (octave < 10)  } { sc.semitones.wrapAt(i) + 36 }
	{ ((octave == 10) or: (octave > 10)) and: (octave < 11)  } { sc.semitones.wrapAt(i) + 37 }
	{ ((octave == 11) or: (octave > 11))  and: (octave < 12)  } { sc.semitones.wrapAt(i) +  38 }
	{ ((octave == 12) or: (octave > 12)) and: (octave < 13)  } { sc.semitones.wrapAt(i) + 48 }
	{ ((octave == 13) or: (octave > 13)) and: (octave < 14 )  } { sc.semitones.wrapAt(i) + 49 }
	{ ((octave == 14) or: (octave > 14)) and: (octave < 15 )   } { sc.semitones.wrapAt(i) +  50 }

	{ ((octave == 15) or: (octave > 15)) and: (octave < 16)  } { sc.semitones.wrapAt(i) + 60 }
	{ ((octave == 16) or: (octave > 16)) and: (octave < 17 )  } { sc.semitones.wrapAt(i) + 61 }
	{ ((octave == 17) or: (octave > 17)) and: (octave < 18 )   } { sc.semitones.wrapAt(i) +  62 }

	{ ((octave == 18) or: (octave > 18)) and: (octave < 19)  } { sc.semitones.wrapAt(i) + 72 }
	{ ((octave == 19) or: (octave > 19)) and: (octave < 20 )  } { sc.semitones.wrapAt(i) + 73 }
	{ ((octave == 20) or: (octave > 20)) and: (octave < 21 )   } { sc.semitones.wrapAt(i) +  74 }

	{ ((octave == 21) or: (octave > 21)) and: (octave < 22)  } { sc.semitones.wrapAt(i) + 84 }
	{ ((octave == 22) or: (octave > 22)) and: (octave < 23 )  } { sc.semitones.wrapAt(i) + 85 }
	{ ((octave == 23) or: (octave > 23)) and: (octave < 24 )   } { sc.semitones.wrapAt(i) +  86 }

	{ ((octave == 24) or: (octave > 24)) and: (octave < 25)  } { sc.semitones.wrapAt(i) + 96 }
	{ ((octave == 25) or: (octave > 25)) and: (octave < 26 )  } { sc.semitones.wrapAt(i) + 97 }
	{ ((octave == 26) or: (octave > 26)) and: (octave < 27 )   } { sc.semitones.wrapAt(i) +  98 }

	{ ((octave == 27) or: (octave > 27)) and: (octave < 28)  } { sc.semitones.wrapAt(i) + 108 }
	{ ((octave == 28) or: (octave > 28)) and: (octave < 29 )  } { sc.semitones.wrapAt(i) + 109 }
	{ ((octave == 29) or: (octave > 29)) and: (octave < 30 )   } { sc.semitones.wrapAt(i) +  110 }

	{ ((octave == 30) or: (octave > 30)) and: (octave < 31)  } { sc.semitones.wrapAt(i) + 120 }
	{ ((octave == 31) or: (octave > 31)) and: (octave < 32 )  } { sc.semitones.wrapAt(i) + 121 }
	{ ((octave == 32) or: (octave > 32))  } { sc.semitones.wrapAt(i) +  122 }
});

	~toneCollection = Array.fill(16, {|i|  ~oton[i * 8 ] });


~m = MonomeGrid.new();

s.waitForBoot({

	var draw, seq, cols = 16, rows = 8;


	~print_paths = "/media/numina/Datapanic/Dropbox/ARCHIVAL_consciousness/print_samples/*.wav".pathMatch;
	~type_paths = "/media/numina/Datapanic/Dropbox/ARCHIVAL_consciousness/typewriter_samples/*.wav".pathMatch;

	~print_samples = ~print_paths.collect{|i| Buffer.read(s, i); };
	~type_samples = ~type_paths.collect{|i| Buffer.read(s, i); };


	MonomeGrid.setAddCallback({
	 arg serial, port, prefix;
	("gridje is er : " ++ serial ++ " " ++ port ++ " " ++ prefix).postln;
	if ( serial == MonomeGrid.getConnectedDevices[0], {
		cols = ~m.cols;
		rows = ~m.rows;
	});
});

	~relSpec = [ 0.01,3.0, \linear,0.01].asSpec;
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
		if ((z == 1) && (y <= (~lastRow-4)), {
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

		if ( ( z == 1) && (y == ~lastRow ), {
			~relBus.set( ~relSpec.map(x/15 ).postln; ); });

		if ( ( z == 1) && (y == (~lastRow-1) ), {
			~seq_int = ~seq_int_spec.map(x/15).postln;

			 });

		if ( ( z == 1) && (y == (~lastRow-2) ), {
			~posBus.set( ~posSpec.map(x/15).postln; ); });


		 if ( ( z == 1) && (y == 4 ), {
	"rate : ".postln;

			~rateBus.set( ((~toneCollection[x]/55) + 0.1).postln; );
 });



			 });





	seq = Routine({

		    loop {

			~play_pos = ( ~play_pos + 1 ).wrap(0, ~lastCol);

			for(0, 3, {arg t;

				if (~step[(t*16) + ~play_pos] == 1,

					{
						"press".postln;


						//if ( ~synth_arr[(t*16) + ~play_pos] == nil, {
							//"nil".postln;

					case
						{ t == 0 } { "0".postln;
							~synth_arr.put( (t*16) + ~play_pos,
							Synth(\bufamp,[\bufnum, ~print_samples[0],
									\pan, -0.8,
									\amp, 0.5,
							        \rateBus, ~rateBus.index,
									\relBus, ~relBus.index,
                                    \posBus, ~posBus.index
						]); ); }
						{ t == 1 }
						{
							~synth_arr.put( (t*16) + ~play_pos,
							Synth(\bufamp,[\bufnum, ~print_samples[1],
									\pan, -0.25,
									\amp, 0.5,
							        \rateBus, ~rateBus.index,
									\relBus, ~relBus.index,
                                    \posBus, ~posBus.index
						]); ); }
						{ t == 2 } {
							~synth_arr.put( (t*16) + ~play_pos,
							Synth(\bufamp,[\bufnum, ~type_samples[0],
									\pan, 0.25,
									\amp, 0.5,
							        \rateBus, ~rateBus.index,
									\relBus, ~relBus.index,
                                    \posBus, ~posBus.index
						]); ); }
						{ t == 3 }
						{
							~synth_arr.put( (t*16) + ~play_pos,
							Synth(\bufamp,[\bufnum, ~type_samples[1],
									\pan, 0.8,
									\amp, 0.5,
							        \rateBus, ~rateBus.index,
									\relBus, ~relBus.index,
                                    \posBus, ~posBus.index
						]); ); };



							//("synth nr " ++ ~synth_arr[(t*16) + ~play_pos] ++ " on ").postln;

							//~relBus.get({|i| ~releaseVar = i; });



						/*	fork{ var current;
								current =  (t*16) + ~play_pos;
								~releaseVar.wait;
								("synth nr " ++ current ++ " off ").postln;
								~synth_arr.put(current, nil);
								~step[current] = 0; };*/



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

			for(0, ~lastRow-4, {arg y;
				~m.led(x, y, (~step[y*16+x] * 11) + (highlight));
			});

		~m.led(x, ~lastRow, 4);
		~m.led(x, ~lastRow-1, 4);
		~m.led(x, ~lastRow-2, 4);
		~m.led(x, ~lastRow-3, 4);
		});

		for(0, ~lastRow-4, {arg t;

				if(~step[(t*16) + ~play_pos ] == 1,
					{~m.led(t, ~lastRow-1, 15); }
				);
			});


	};

	seq.play(~clock);

});



)