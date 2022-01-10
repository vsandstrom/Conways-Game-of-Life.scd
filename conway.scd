// Conways "Game of Life"
// adapted from P5.js example

s.options.memSize = 8192 * 16;
s.options.outDevice = "BlackHole 16ch";
s.options.Devices

s.reboot;

s.waitForBoot({

	var win, board, nextBoard, rows, columns, tempBoard, game;

	//MACROs
	var width = 1680, height = 1020, tile = 20, rate = 0.4;
	
	~total = 0;
	~alive = 0;
	~dead = 0;

	SynthDef(\fm, {
		|freq=500, mRatio=1, mRatio2=1, cRatio=1, index=1, iScale=5, fb=0.5, out=0, ffreq=3000, dt=0.1,
		atk = 4, rel= 4, cAtk=4, cRel=(-4), amp=0.04, gt=1|
		var car,mod,env,ienv,mod2,local,lpf,fbenv,localmod;

		ienv = EnvGen.kr(
			Env.new(
				[index,index*iScale,index],
				[atk,rel],
				[cAtk,cRel]
			),
			\t_trig.kr(0);
		);

		fbenv = EnvGen.kr(
			Env.asr(atk,2,rel),
			Trig.kr(gt,4)
		);

		local = LocalIn.ar(2);
		localmod = local*fbenv;//

		env = EnvGen.ar(
			Env.perc(
				atk,
				rel, 
				curve:[cAtk,cRel]
			), 
			\t_trig.kr(0),
			doneAction: 2
		);

		mod2 = SinOsc.ar(freq*mRatio2+localmod,0,freq* mRatio2 * ienv);
		mod = SinOsc.ar(freq*mRatio+mod2,0,freq* mRatio * ienv);
		car = SinOsc.ar(freq*cRatio+mod);
		
		local = local + [car, 0]; //
		local = DelayN.ar(local, 0.2, dt);

		LocalOut.ar(local*fb);
		lpf = DFM1.ar(local*env*amp,ffreq);
		// lpf = BLowPass4.ar(local*env*amp,ffreq);
		//pant = Pan2.ar(local,pan);
		Out.ar(out, Pan2.ar(lpf.tanh, \pan.kr(0)));
	}).add;

	win = Window(\gameOfLife, Rect(100, 100, width, height)).front;
	win.view.background_(Color(255));

	columns = (width / tile).floor;
	rows = (height / tile).floor;

	~total = columns * rows;

	board = Array.fill2D(columns, rows, 0);
	nextBoard = Array.fill2D(columns, rows, 0);

	game = Routine{ 
		var blue = 80, green = 40;
		var synth, fbVal = 0, panVal = 0, left = 0, right = 0; 
		var freq = 300;

		for (0, ( columns -1 )) {|i|
			for (0, ( rows -1 )) {|j|
				// create padding around edges
				if(i==0 || j == 0 || i == ( columns -1) || j == ( rows -1)) {
					board[i][j] = 0;
				} {
					// randomly fill array
					board.wrapAt(i).wrapPut(j, [0, 1].choose);
					
				};
				// clear previous board for new input
				nextBoard.wrapAt(i).wrapPut(j, 0);
			};
		};
		{Out.ar(0, Compander.ar(In.ar(0, 2)))}.play;
		{Out.ar(0, NHHall.ar(In.ar(0, 2), 8))}.play;
		// {Out.ar(0, FreeVerb.ar(In.ar(0, 2)), 0.6, 0.7)}.play;

		Synth(\fm, [
			\fb, ((1.0 / ~total)* ~dead), 
			\dt, rrand(0.01,0.08),
			\atk, rrand(1,4),
			\freq, (freq*[4,6,8].choose),
			\mRatio, [3, 5, 6, 9].choose,
			\mRatio2, [0.5, 2, 5, 7, 9].choose,
			\cRatio, rrand(1,2),
			\index, rrand(1,2),
			\iScale, 1,
			\gt, 1,
			\t_trig, 1,
			\rel, 24,
			\ffreq, rrand(1000,6000),
			\amp, 0.014
			]
		);

		loop{
			// Loop through arrays
			for (0, ( columns -1 )) {|i|
				for (0, ( rows -1 )) {|j|
					var nbor = 0;
					// Count neighbors (nbor)
					for(-1, 1) {|x|
						for (-1, 1) {|y|
							nbor = nbor + board.wrapAt((i + x)).wrapAt((j + y));
						};
					};
					nbor = nbor - board[i][j];

					//Rules of life:
					if((board[i][j] == 1) && (nbor < 2)){ nextBoard[i][j] = 0;
						if (i < (columns / 2)) {
							left = left + 1;
						} {
							right = right + 1;
						}
					};

					if((board[i][j] == 1) && (nbor > 3)) {
						nextBoard[i][j] = 0;
						if (i < (columns / 2)) {
							left = left + 1;
						} {
							right = right + 1;
						};
					};

					if((board[i][j] == 0) && (nbor == 3)) {
						nextBoard[i][j] = 1;
					};

					if((((board[i][j] == 1) && (nbor == 3)) || ((board[i][j] == 1) && (nbor == 2)) || ((board[i][j] == 0) && (nbor != 3)))) {
						// if nothing has changed, keep tile the same for next iteration.
						nextBoard[i][j] = board[i][j];
						if (i < (columns / 2)) {
							left = left - 1;
						} {
							right = right - 1;
						};

					};
				};
			};

			// draw
			win.drawFunc = {
			for (0, (columns -1)) {|i|
				for (0, (rows -1)) {|j|
						if(board[i][j] == 1) {
							// nice red color for tiles, changes on blue and green per iteration.
							Pen.color_(Color.new255(rrand(160, 240), (blue % 256), (green % 256), 200));
							Pen.addRect(Rect(i*tile, j*tile, tile-1, tile-1));
						} {
							Pen.color_(Color(255));
							Pen.addRect(Rect(i*tile, j*tile, tile-1, tile-1));
						};
						Pen.perform(\fill);
					};
				};
			};
			// count alive / count dead
			for (0, columns -1) {|i|
				~alive = ~alive + board[i].count({|item, i| item.odd});
			};

			~dead = ~total - ~alive;

			// do some calculations - Find musical values
			
			// do more feedback when more cells are dead
			fbVal = ((0.5 / ~total) * ~dead);
	
			// create panning value
			right = (1 / (right + left) * right);
			left = (1 / (right + left) * left);
			panVal = (right -  left) + 0.5;
			if (panVal > 0) {
				panVal = 0.77;
			} {
				panVal = -0.77;
			};

			if ((~total % ~alive == 0) ||  (~alive % columns == 0)) {
				Synth(\fm, [
					\fb, fbVal, 
					\dt, rrand(0.01,0.08),
					\atk, rrand(1,4),
					\freq, (freq * [0.5, 1, 3, 5, 9]).choose,
					\mRatio, [3, 5, 6, 9].choose,
					\mRatio2, [0.5, 2, 5, 7, 9].choose,
					\cRatio, [1, 2, 3, 5, 7].choose,
					\index, [1, 1.3, 1.6, 2].choose,
					\iScale, 1,
					\gt, 1,
					\t_trig, 1,
					\rel, 24,
					\pan, panVal,
					\ffreq, rrand(1000,6000),
					\amp, 0.004
					]
				);
			};
			
			if ((~total % ~alive == 0) || (~alive % rows == 0)) {
				Synth(\fm, [
					\fb, fbVal, 
					\dt, rrand(0.01,0.08),
					\atk, rrand(1,4),
					\freq, ((freq * 2.5) * [0.5, 1, 3, 5, 9]).choose,
					\mRatio, [3, 5, 6, 9].choose,
					\mRatio2, [0.5, 2, 5, 7, 9].choose,
					\cRatio, [1, 2, 3, 5, 7].choose,
					\index, [1, 1.3, 1.6, 2].choose,
					\iScale, 1,
					\gt, 1,
					\t_trig, 1,
					\rel, 24,
					\pan, panVal,
					\ffreq, rrand(1000,6000),
					\amp, 0.004
					]
				);
			};

			Post << "Alive cells: " << ~alive << ", Dead cells: " << ~dead << Char.nl;

			~alive = 0;
			~dead = 0;

			// swap
			tempBoard = board;
			board = nextBoard;
			nextBoard = tempBoard;

			win.refresh;
			rate.wait;
			
			blue = blue + 2;
			green = green + 4;
			right = 0;
			left = 0;
		};
	};
	
	AppClock.play(game);
});

