package dn;

class Bresenham {
	/**
		The "Thin" methods work on regular "pixel perfect" bresenhman lines, like:
			###
			   ###
			      ###

	  The "Thick" versions are slightly thicker when getting pixels in diagonal:
			###
			  ####
			     ####

	**/

	public static function getThinLine(x0:Int, y0:Int, x1:Int, y1:Int, ?respectOrder=false) : Array<{x:Int, y:Int}> {
		var pts = [];
		var swapXY = M.iabs( y1 - y0 ) > M.iabs( x1 - x0 );
		var swapped = false;
        var tmp : Int;
        if ( swapXY ) {
            // swap x and y
            tmp = x0; x0 = y0; y0 = tmp; // swap x0 and y0
            tmp = x1; x1 = y1; y1 = tmp; // swap x1 and y1
        }
        if ( x0 > x1 ) {
            // make sure x0 < x1
            tmp = x0; x0 = x1; x1 = tmp; // swap x0 and x1
            tmp = y0; y0 = y1; y1 = tmp; // swap y0 and y1
			swapped = true;
        }
        var deltax = x1 - x0;
        var deltay = M.floor( M.iabs( y1 - y0 ) );
        var error = M.floor( deltax / 2 );
        var y = y0;
        var ystep = if ( y0 < y1 ) 1 else -1;
		if( swapXY )
			// Y / X
			for ( x in x0 ... x1+1 ) {
				pts.push({x:y, y:x});
				error -= deltay;
				if ( error < 0 ) {
					y+=ystep;
					error = error + deltax;
				}
			}
		else
			// X / Y
			for ( x in x0 ... x1+1 ) {
				pts.push({x:x, y:y});
				error -= deltay;
				if ( error < 0 ) {
					y+=ystep;
					error = error + deltax;
				}
			}

		if( swapped && respectOrder )
			pts.reverse();

		return pts;
	}



	@:noCompletion
	@:deprecated("Use getThickLine() instead")
	public static inline function getFatLine(x0:Int, y0:Int, x1:Int, y1:Int, ?respectOrder=false) {
		return getThickLine(x0,y0,x1,y1,respectOrder);
	}
	public static function getThickLine(x0:Int, y0:Int, x1:Int, y1:Int, ?respectOrder=false) {
		var pts = [];
		var swapXY = M.iabs( y1 - y0 ) > M.iabs( x1 - x0 );
		var swapped = false;
        var tmp : Int;
        if ( swapXY ) {
            // swap x and y
            tmp = x0; x0 = y0; y0 = tmp; // swap x0 and y0
            tmp = x1; x1 = y1; y1 = tmp; // swap x1 and y1
        }
        if ( x0 > x1 ) {
			swapped = true;
            // make sure x0 < x1
            tmp = x0; x0 = x1; x1 = tmp; // swap x0 and x1
            tmp = y0; y0 = y1; y1 = tmp; // swap y0 and y1
        }
        var deltax = x1 - x0;
        var deltay = M.floor( M.iabs( y1 - y0 ) );
        var error = M.floor( deltax / 2 );
        var y = y0;
        var ystep = if ( y0 < y1 ) 1 else -1;

		if( swapXY )
			// Y / X
			for ( x in x0 ... x1+1 ) {
				pts.push({x:y, y:x});

				error -= deltay;
				if ( error < 0 ) {
					if( x<x1 ) {
						pts.push({x:y+ystep, y:x});
						pts.push({x:y, y:x+1});
					}
					y+=ystep;
					error = error + deltax;
				}
			}
		else
			// X / Y
			for ( x in x0 ... x1+1 ) {
				pts.push({x:x, y:y});

				error -= deltay;
				if ( error < 0 ) {
					if( x<x1 ) {
						pts.push({x:x, y:y+ystep});
						pts.push({x:x+1, y:y});
					}
					y+=ystep;
					error = error + deltax;
				}
			}

		if( swapped && respectOrder )
			pts.reverse();

		return pts;
	}


	// Source : http://en.wikipedia.org/wiki/Midpoint_circle_algorithm
	// Duplicates fix: https://stackoverflow.com/questions/44117168/midpoint-circle-without-duplicates
	public inline static function getCircle(x0,y0,radius) {
		var pts = [];
		iterateCircle(x0, y0, radius, function(x,y) pts.push( { x:x, y:y } ));
		return pts;
	}



	// Source : http://stackoverflow.com/questions/1201200/fast-algorithm-for-drawing-filled-circles
	public static function getDisc(x0,y0,radius) {
		var pts = [];
		iterateDisc(x0, y0, radius, function(x,y) pts.push( { x:x, y:y } ));
		return pts;
	}

	static inline function _iterateHorizontal(fx,fy, tx, cb:Int->Int->Void) {
		for(x in fx...tx+1)
			cb(x,fy);
	}

	public static function iterateDisc(x0,y0,radius, cb:Int->Int->Void) {
		var x = radius;
		var y = 0;
		var radiusError = 1-x;
		while( x>=y ) {
			_iterateHorizontal(-x+x0, y+y0, x+x0, cb); // WWS

			if( ( radius<=1 || x!=y && y!=0 ) && radiusError>=0 )
				_iterateHorizontal(-y+x0, x+y0, y+x0, cb); // WSS

			if( y!=0 )
				_iterateHorizontal(-x+x0, -y+y0, x+x0, cb); // WWN

			if( ( radius<=1 || x!=y && y!=0 ) && radiusError>=0 )
				_iterateHorizontal(-y+x0, -x+y0, y+x0, cb); // WNN

			y++;
			if( radiusError<0 )
				radiusError += 2*y+1;
			else {
				x--;
				radiusError += 2*(y-x+1);
			}
		}
	}


	public static function iterateCircle(x0,y0,radius, cb:Int->Int->Void) {
		var x = radius;
		var y = 0;
		var radiusError = 1-x;
		while( x>=y ) {
			cb(x+x0, y+y0); // EES
			cb(-x+x0, y+y0); // WWS

			if( x!=y ) {
				cb(y+x0, x+y0); // ESS
				if( y!=0 )
					cb(-y+x0, x+y0); // WSS
			}

			if( y!=0 ) {
				cb(x+x0, -y+y0); // EEN
				cb(-x+x0, -y+y0); // WWN
			}

			if( x!=y ) {
				cb(y+x0, -x+y0); // ENN
				if( y!=0 )
					cb(-y+x0, -x+y0); // WNN
			}

			y++;
			if( radiusError<0 )
				radiusError += 2*y+1;
			else {
				x--;
				radiusError += 2*(y-x+1);
			}
		}
	}


	public inline static function iterateThinLine(x0:Int,y0:Int, x1:Int,y1:Int, cb:Int->Int->Void) {
		var swapXY = M.iabs( y1 - y0 ) > M.iabs( x1 - x0 );
		var tmp : Int;
		if ( swapXY ) {
			// swap x and y
			tmp = x0; x0 = y0; y0 = tmp; // swap x0 and y0
			tmp = x1; x1 = y1; y1 = tmp; // swap x1 and y1
		}
		if ( x0 > x1 ) {
			// make sure x0 < x1
			tmp = x0; x0 = x1; x1 = tmp; // swap x0 and x1
			tmp = y0; y0 = y1; y1 = tmp; // swap y0 and y1
		}
		var deltax = x1 - x0;
		var deltay = Math.floor( M.iabs( y1 - y0 ) );
		var error = Math.floor( deltax / 2 );
		var y = y0;
		var ystep = if ( y0 < y1 ) 1 else -1;

		for ( x in x0 ... x1+1 ) {
			if( swapXY )
				cb(y,x);
			else
				cb(x,y);
			error -= deltay;
			if ( error < 0 ) {
				y+=ystep;
				error = error + deltax;
			}
		}
	}


	public inline static function iterateThickLine(x0:Int,y0:Int, x1:Int,y1:Int, cb:Int->Int->Void) {
		var swapXY = M.iabs( y1 - y0 ) > M.iabs( x1 - x0 );
		var tmp : Int;
		if ( swapXY ) {
			// swap x and y
			tmp = x0; x0 = y0; y0 = tmp; // swap x0 and y0
			tmp = x1; x1 = y1; y1 = tmp; // swap x1 and y1
		}
		if ( x0 > x1 ) {
			// make sure x0 < x1
			tmp = x0; x0 = x1; x1 = tmp; // swap x0 and x1
			tmp = y0; y0 = y1; y1 = tmp; // swap y0 and y1
		}
		var deltax = x1 - x0;
		var deltay = Math.floor( M.iabs( y1 - y0 ) );
		var error = Math.floor( deltax / 2 );
		var y = y0;
		var ystep = if ( y0 < y1 ) 1 else -1;

		for ( x in x0 ... x1+1 ) {
			if( swapXY )
				cb(y,x);
			else
				cb(x,y);

			error -= deltay;
			if ( error < 0 ) {
				if( x<x1 )
					if( swapXY )
						cb(y,x+1);
					else
						cb(x+1,y);
				y+=ystep;
				error = error + deltax;
			}
		}
	}



	// Vérifie que tous les points d'une ligne sont valides: si rayCanPass(x,y) renvoie FALSE sur
	// un point (ie. obstacle), toute la méthode renvoie FALSE
	public inline static function checkThinLine(x0:Int,y0:Int, x1:Int,y1:Int, rayCanPass:Int->Int->Bool) {
		if( !rayCanPass(x0,y0) || !rayCanPass(x1,y1) ){
			return false;
		}else{
			var swapXY = M.iabs( y1 - y0 ) > M.iabs( x1 - x0 );
			var tmp : Int;
			if ( swapXY ) {
				// swap x and y
				tmp = x0; x0 = y0; y0 = tmp; // swap x0 and y0
				tmp = x1; x1 = y1; y1 = tmp; // swap x1 and y1
			}
			if ( x0 > x1 ) {
				// make sure x0 < x1
				tmp = x0; x0 = x1; x1 = tmp; // swap x0 and x1
				tmp = y0; y0 = y1; y1 = tmp; // swap y0 and y1
			}
			var deltax = x1 - x0;
			var deltay = Math.floor( M.iabs( y1 - y0 ) );
			var error = Math.floor( deltax / 2 );
			var y = y0;
			var ystep = if ( y0 < y1 ) 1 else -1;
			var valid = true;

			for ( x in x0 ... x1+1 ) {
				if( swapXY && !rayCanPass(y,x) || !swapXY && !rayCanPass(x,y) ){
					valid = false;
					break;
				}
				error -= deltay;
				if ( error < 0 ) {
					y+=ystep;
					error = error + deltax;
				}
			}
			return valid;
		}
	}


	@:noCompletion
	@:deprecated("Use checkThickLine() instead")
	public static inline function checkFatLine(x0:Int,y0:Int, x1:Int,y1:Int, rayCanPass:Int->Int->Bool) {
		return checkThickLine(x0,y0,x1,y1,rayCanPass);
	}
	public inline static function checkThickLine(x0:Int,y0:Int, x1:Int,y1:Int, rayCanPass:Int->Int->Bool) {
		if( !rayCanPass(x0,y0) || !rayCanPass(x1,y1) ){
			return false;
		}else{
			var swapXY = M.iabs( y1 - y0 ) > M.iabs( x1 - x0 );
			var tmp : Int;
			if ( swapXY ) {
				// swap x and y
				tmp = x0; x0 = y0; y0 = tmp; // swap x0 and y0
				tmp = x1; x1 = y1; y1 = tmp; // swap x1 and y1
			}
			if ( x0 > x1 ) {
				// make sure x0 < x1
				tmp = x0; x0 = x1; x1 = tmp; // swap x0 and x1
				tmp = y0; y0 = y1; y1 = tmp; // swap y0 and y1
			}
			var deltax = x1 - x0;
			var deltay = M.floor( M.iabs( y1 - y0 ) );
			var error = M.floor( deltax / 2 );
			var y = y0;
			var ystep = if ( y0 < y1 ) 1 else -1;
			var valid = true;

			if( swapXY )
				// Y / X
				for ( x in x0 ... x1+1 ) {
					if( !rayCanPass(y,x) ){
						valid = false;
						break;
					}

					error -= deltay;
					if ( error < 0 ) {
						if( x<x1 && ( !rayCanPass(y+ystep, x) || !rayCanPass(y, x+1) ) ){
							valid = false;
							break;
						}
						y += ystep;
						error += deltax;
					}
				}
			else
				// X / Y
				for ( x in x0 ... x1+1 ) {
					if( !rayCanPass(x,y) ){
						valid = false;
						break;
					}

					error -= deltay;
					if ( error < 0 ) {
						if( x<x1 && ( !rayCanPass(x, y+ystep) || !rayCanPass(x+1, y) ) ){
							valid = false;
							break;
						}
						y += ystep;
						error += deltax;
					}
				}
			return valid;
		}
	}


	@:noCompletion
	public static function __test() {
		CiAssert.noException(
			"Bresenham disc radius",
			iterateDisc(0,0, 2, function(x,y) {
				if( M.floor( Math.sqrt( x*x + y*y ) ) > 2 )
					throw 'Failed at $x,$y';
			})
		);
		CiAssert.noException(
			"Bresenham circle radius",
			iterateCircle(0,0, 2, function(x,y) {
				if( M.round( Math.sqrt( x*x + y*y ) ) != 2 )
					throw 'Failed at $x,$y';
			})
		);

	}
}

