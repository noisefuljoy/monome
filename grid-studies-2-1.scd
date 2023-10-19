(
Server.default = Server.local;

// MonomeGrid accepts three arguments:
// * rotation (0 is default)
// * prefix (a string nickname for this grid)
// * fps (frames per second)

~m = MonomeGrid.new(rotation: 0, prefix: "/monome", fps: 60);



s.waitForBoot({
	var draw;

	~m.connect(0); // 0 (or not supplying any argument) means the first-connected device
     ~step = Array.fill(~m.cols * ~m.rows, { 0 } );

	~m.key({
		arg x,y,z;
		[x,y,z, "serial: " ++~m.serial,"port: "++~m.port].postln;
		//~m.led(x, y, z*25);
		if ( z == 1, {
			var pos = x + (y*16);
			if ( ~step[pos] == 1,
					{ ~step[pos] = 0 },
				    { ~step[pos] = 1 });
			draw.value(x, y);


		});

	});

	draw = { arg x, y;
				~m.led( x, y, ~step[y*16+x] * 15);  };


});


)


~m.serial
~m.prefix
~m.port
~m.rotation
~m.dvcnum

MonomeGrid.prefixes
MonomeGrid.portlst
MonomeGrid.connectedDevices
MonomeGrid.deviceList
MonomeGrid.p