package dn.heaps;

class Scaler {
	/** Can be replaced with other methods to change how reference "viewport" width is determined **/
	public static dynamic function getViewportWidth() return hxd.Window.getInstance().width;

	/** Can be replaced with other methods to change how reference "viewport" height is determined **/
	public static dynamic function getViewportHeight() return hxd.Window.getInstance().height;


	/** Fit `wid`x`hei` in current viewport, optionally snapping to closest Integer scale value (for pixel perfect rendering) **/
	public static function bestFit_f(widPx:Float, heiPx:Float, ?contextWid:Float, ?contextHei:Float, integerScale=true) : Float {
		var sx = ( contextWid==null ? getViewportWidth() : contextWid ) / widPx;
		var sy = ( contextHei==null ? getViewportHeight() : contextHei ) / heiPx;
		if( integerScale ) {
			sx = M.floor(sx);
			sy = M.floor(sy);
		}
		return M.fmax(1, M.fmin(sx,sy) );
	}


	/** Fit `wid`x`hei` in current viewport, while keeping scaling value as Int **/
	public static inline function bestFit_i(widPx:Float, heiPx:Float, ?contextWid:Float, ?contextHei:Float) : Int {
		return Std.int( bestFit_f(widPx, heiPx, contextWid, contextHei, true) );
	}
}