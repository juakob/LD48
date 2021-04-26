package dn;

// Parker-Miller-Carta LCG

/*
	Known issues :
	- don't use negative seeds
	- first random(7) is 0 or 6 for small seeds
	  and some correlated random results can appear for
	  multiples of 7
*/

class Rand {

	#if old_f9rand
	var seed : UInt;
	#else
	var seed : #if (flash9 || cpp || hl || neko) Float #else Int #end;
	#end

	public function new( seed : Int ) {
		this.seed = ((seed < 0) ? -seed : seed) + 131;
	}

	public inline function clone() {
		var r = new Rand(0);
		r.seed = seed;
		return r;
	}

	/**
	 * @return an int within the 30 bit int range
	 * int bits are not fully distributed, so it works well with small modulo
	 */
	public inline function random( n ) : Int {

		#if neko
			return if( n == 0 ) int() * 0 else int() % n;
		#elseif flash
			return int() % n;
		#else
		/*	#if debug
				if (n == 0)
					throw "WARNING : random(0) is invalid for non neko/flash targets" ;
			#end */
			return int() % n;
		#end
	}

	public inline function range(min:Float, max:Float,?randSign=false) { // tirage inclusif [min, max]
		return ( min + rand() * (max-min) ) * (randSign ? random(2)*2-1 : 1);
	}

	public inline function irange(min:Int, max:Int, ?randSign=false) { // tirage inclusif [min, max]
		return ( min + random(max-min+1) ) * (randSign ? random(2)*2-1 : 1);
	}

	public function getSeed() {
		return Std.int(seed) - 131;
	}

	public #if !hl inline #end function arrayPick<T>(a:Array<T>) : Null<T> {
		return a.length==0 ? null : a[random(a.length)];
	}
	public #if !hl inline #end function arraySplice<T>(a:Array<T>) : Null<T> {
		return a.length==0 ? null : a.splice(random(a.length),1)[0];
	}
	public #if !hl inline #end function vectorPick<T>(a:haxe.ds.Vector<T>) : Null<T> {
		return a.length==0 ? null : a[random(a.length)];
	}

	/**
	 * @return a [0-1] float with a precision of 1/10007
	 * @see random() for int retrieval
	 */
	public inline function rand() : Float{
		// we can't use a divider > 16807 or else two consecutive seeds
		// might generate a similar float
		return (int() % 10007) / 10007.0;
	}

	public inline function sign() {
		return random(2)*2-1;
	}

	public inline function addSeed( d : Int ) {
		#if neko
		seed = untyped __dollar__int((seed + d) % 2147483647.0) & 0x3FFFFFFF;
		#elseif (flash9 || cpp || hl)
		seed = Std.int((seed + d) % 2147483647.0) & 0x3FFFFFFF;
		#else
		seed = ((seed + d) % 0x7FFFFFFF) & 0x3FFFFFFF;
		#end
		if( seed == 0 ) seed = d + 1;
	}

	public function initSeed( n : Int, ?k = 5 ) {
		// we are using a double hashing function
		// that we loop K times. It seems to provide
		// good-enough randomness. In case it doesn't,
		// we can use an higher K
		for( i in 0...k ) {
			n ^= (n << 7) & 0x2b5b2500;
			n ^= (n << 15) & 0x1b8b0000;
			n ^= n >>> 16;
			n &= 0x3FFFFFFF;
			var h = 5381;
			h = (h << 5) + h + (n & 0xFF);
			h = (h << 5) + h + ((n >> 8) & 0xFF);
			h = (h << 5) + h + ((n >> 16) & 0xFF);
			h = (h << 5) + h + (n >> 24);
			n = h & 0x3FFFFFFF;
		}
		seed = (n & 0x1FFFFFFF) + 131;
	}

	/**
	 * int bits are not fully distributed, so it works well with small modulo
	 * @return an int
	 */
	inline function int() : Int {
		#if neko
		return untyped __dollar__int( seed = (seed * 16807.0) % 2147483647.0 ) & 0x3FFFFFFF;
		#elseif (flash9 || cpp || hl)
			#if old_f9rand
			return seed = Std.int((seed * 16807.0) % 2147483647.0) & 0x3FFFFFFF;
			#else
			return Std.int(seed = (seed * 16807.0) % 2147483647.0) & 0x3FFFFFFF;
			#end
		#else
		return (seed = (seed * 16807) % 0x7FFFFFFF) & 0x3FFFFFFF;
		#end
	}



	public static function __test() {
		var random = new Rand(0);
		for(i in 0...20) {
			var seed = Std.random(999999);
			random.initSeed(seed);
			var a = random.rand();
			random.initSeed(seed);
			CiAssert.printIfVerbose("Seed="+seed+":");
			CiAssert.equals( random.rand(), a );
		}

	}

}
