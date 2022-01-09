// Conways "Game of Life"
// adapted from P5.js example
s.waitForBoot({

	var win, board, nextBoard, rows, columns, tempBoard, game;

	//MACROs
	var width = 1680, height = 1020, tile = 20, rate = 0.4;

	win = Window(\gameOfLife, Rect(100, 100, width, height)).front;
	win.view.background_(Color(255));

	columns = (width / tile).floor;
	rows = (height / tile).floor;

	board = Array.fill2D(columns, rows, 0);
	nextBoard = Array.fill2D(columns, rows, 0);

	game = Routine{ 
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
					};
					if((board[i][j] == 1) && (nbor > 3)) {
						nextBoard[i][j] = 0;
					};
					if((board[i][j] == 0) && (nbor == 3)) {
						nextBoard[i][j] = 1;
					};
					if((((board[i][j] == 1) && (nbor == 3)) || ((board[i][j] == 1) && (nbor == 2)) || ((board[i][j] == 0) && (nbor != 3)))) {
						// if nothing has changed, keep tile the same for next iteration.
						nextBoard[i][j] = board[i][j];
					};
				};
			};

			// draw
			win.drawFunc = {
			for (0, (columns -1)) {|i|
				for (0, (rows -1)) {|j|
						if(board[i][j] == 1) {
							// nice red color for tiles
							Pen.color_(Color.new255(rrand(160, 240), 80, 50, 200));
							Pen.addRect(Rect(i*tile, j*tile, tile-1, tile-1));
						} {
							Pen.color_(Color(255));
							Pen.addRect(Rect(i*tile, j*tile, tile-1, tile-1));
						};
						Pen.perform(\fill);
					};
				};
			};
			// swap
			tempBoard = board;
			board = nextBoard;
			nextBoard = tempBoard;

			win.refresh;
			rate.wait;
		};
	};

	AppClock.play(game);
});
