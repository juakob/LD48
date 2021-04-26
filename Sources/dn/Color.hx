package dn;

import Type;

typedef Col = {
	r	: Int, // 0-255
	g	: Int, // 0-255
	b	: Int, // 0-255
}
typedef ColHsl = {
	h	: Float, // 0-1
	s	: Float, // 0-1
	l	: Float, // 0-1
}

typedef Col32 = {
	>Col,
	a	: Int, // 0-255
}

typedef Pal = Array<Col>;
typedef PalInt = Array<Int>;

class Color {
	static var HEX_CHARS = "0123456789abcdef";
	public static var BLACK = intToRgb(0x0);
	public static var WHITE = intToRgb(0xffffff);
	public static var MEDIAN_GRAY = intToRgb(0x808080);

	public static var RED_LUMA = 0.299;
	public static var GREEN_LUMA = 0.587;
	public static var BLUE_LUMA = 0.114;

	public static inline function hexToRgb(hex:String) : Col {
		if ( hex==null )
			throw "hexToColor with null";
		if ( hex.indexOf("#")==0 )
			hex = hex.substr(1,999);
		return {
			r	: Std.parseInt("0x"+hex.substr(0,2)),
			g	: Std.parseInt("0x"+hex.substr(2,2)),
			b	: Std.parseInt("0x"+hex.substr(4,2)),
		}
	}

	public static inline function hexToInt(hex:String) {
		return Std.parseInt( "0x"+hex.substr(1,999) );
	}

	/** Turn an hex string to #rrggbb format (supports #rrggbb, #rgb and #v formats) **/
	public static function sanitizeHexStr(hex:String, includeSharp=true) : Null<String> {
		hex = hex==null ? "" : StringTools.trim(hex);
		var reg = ~/^#*([0-9abcdef]{6})|^#*([0-9abcdef]{3})$|^#*([0-9abcdef]{1})$/gi;
		if( reg.match(hex) ) {
			return
				( includeSharp ? "#" : "" )
				+ ( reg.matched(3)!=null
					? { var c = reg.matched(3); c+c + c+c + c+c; }
					: reg.matched(2)!=null
						? { var c = reg.matched(2); c.charAt(0)+c.charAt(0) + c.charAt(1)+c.charAt(1) + c.charAt(2)+c.charAt(2); }
						: reg.matched(1)
				);
		}
		else
			return null;
	}

	public static inline function isValidHex(hex:String) {
		return sanitizeHexStr(hex,false)!=null;
	}

	public static inline function hexToInta(hex:String) {
		return Std.parseInt( "0xff"+hex.substr(1,999) );
	}

	public static inline function rgbToInt(c:Col) : Int{
		return (c.r << 16) | (c.g<<8 ) | c.b;
	}

	public static inline function rgbToHex(c:Col) : String {
		return intToHex( rgbToInt(c) );
	}

	public static inline function rgbToHsl(c:Col) : ColHsl {
		var r = c.r/255;
		var g = c.g/255;
		var b = c.b/255;
		var min = if(r<=g && r<=b) r else if(g<=b) g else b;
		var max = if(r>=g && r>=b) r else if(g>=b) g else b;
		var delta = max-min;

		var hsl : ColHsl = { h:0., s:0., l:0. };
		hsl.l = max;
		if( delta!=0 ) {
			hsl.s = delta/max;
			var dr = ( (max-r)/6 + (delta/2) ) / delta;
			var dg = ( (max-g)/6 + (delta/2) ) / delta;
			var db = ( (max-b)/6 + (delta/2) ) / delta;

			if( r==max ) hsl.h = db-dg;
			else if( g==max ) hsl.h = 1/3 + dr-db;
			else if( b==max ) hsl.h = 2/3 + dg-dr;

			if( hsl.h<0 ) hsl.h++;
			if( hsl.h>1 ) hsl.h--;
		}

		return hsl;
	}


	public static inline function hslToRgb(hsl:ColHsl) : Col {
		var c : Col = {r:0, g:0, b:0};
		var r = 0.;
		var g = 0.;
		var b = 0.;

		if( hsl.s==0 )
			c.r = c.g = c.b = Math.round(hsl.l*255);
		else {
			var h = hsl.h*6;
			var i = M.floor(h);
			var c1 = hsl.l * (1 - hsl.s);
			var c2 = hsl.l * (1 - hsl.s * (h-i));
			var c3 = hsl.l * (1 - hsl.s * (1 - (h-i)));

			if( i==0 || i==6 )	{ r = hsl.l; g = c3; b = c1; }
			else if( i==1 )		{ r = c2; g = hsl.l; b = c1; }
			else if( i==2 )		{ r = c1; g = hsl.l; b = c3; }
			else if( i==3 )		{ r = c1; g = c2; b = hsl.l; }
			else if( i==4 )		{ r = c3; g = c1; b = hsl.l; }
			else 				{ r = hsl.l; g = c1; b = c2; }
			c.r = M.round(r*255);
			c.g = M.round(g*255);
			c.b = M.round(b*255);
		}

		return c;
	}


	public static inline function hslToInt(h:Float, s:Float, l:Float) : Int {
		if( l<=0 )
			return 0x0;
		if( s<=0 )
			return makeColorRgb(l,l,l);
		else {
			var r = 0.;
			var g = 0.;
			var b = 0.;

			h*=6;
			var i = M.floor(h);
			var c1 = l * (1 - s);
			var c2 = l * (1 - s * (h-i));
			var c3 = l * (1 - s * (1 - (h-i)));

			if( i==0 || i==6 )	{ r = l; g = c3; b = c1; }
			else if( i==1 )		{ r = c2; g = l; b = c1; }
			else if( i==2 )		{ r = c1; g = l; b = c3; }
			else if( i==3 )		{ r = c1; g = c2; b = l; }
			else if( i==4 )		{ r = c3; g = c1; b = l; }
			else 				{ r = l; g = c1; b = c2; }

			return makeColorRgb(r,g,b);
		}
	}


	static inline function hslStructToInt(hsl:ColHsl) : Int {
		var r = 0.;
		var g = 0.;
		var b = 0.;

		if( hsl.l>0 ) {
			if( hsl.s==0 )
				r = g = b = hsl.l;
			else {
				var h = hsl.h*6;
				var i = Math.floor(h);
				var c1 = hsl.l * (1 - hsl.s);
				var c2 = hsl.l * (1 - hsl.s * (h-i));
				var c3 = hsl.l * (1 - hsl.s * (1 - (h-i)));

				if( i==0 || i==6 )	{ r = hsl.l; g = c3; b = c1; }
				else if( i==1 )		{ r = c2; g = hsl.l; b = c1; }
				else if( i==2 )		{ r = c1; g = hsl.l; b = c3; }
				else if( i==3 )		{ r = c1; g = c2; b = hsl.l; }
				else if( i==4 )		{ r = c3; g = c1; b = hsl.l; }
				else 				{ r = hsl.l; g = c1; b = c2; }
			}
		}
		return makeColorRgb(r,g,b);
	}


	public static inline function rgbToMatrix(c:Col) {
		var matrix = new Array();
		matrix = matrix.concat([c.r/255, 0, 0, 0, 0]); // red
		matrix = matrix.concat([0, c.g/255, 0, 0, 0]); // green
		matrix = matrix.concat([0, 0, c.b/255, 0, 0]); // blue
		matrix = matrix.concat([0, 0, 0, 1.0, 0]); // alpha
		return matrix;
	}

	public static inline function intToHex(c:Int, leadingZeros=6, includeSharp=true) : String {
		return ( includeSharp ? "#" : "" ) + StringTools.hex(c, leadingZeros);
	}

	public static inline function intToHexARGB(c:Int, includeSharp=true) : String {
		return ( includeSharp ? "#" : "" ) + StringTools.hex(c, 8);
	}

	public static inline function intToHexRGBA(c:Int, includeSharp=true) : String {
		return ( includeSharp ? "#" : "" )
			+ StringTools.hex(removeAlpha(c), 6)
			+ StringTools.hex(getAlpha(c), 2);
	}

	public static inline function intToHex3(c:Int) : String {
		var h = StringTools.hex(c,6);
		return HEX_CHARS.charAt( M.round( getR(c)*15 ) )
			+ HEX_CHARS.charAt( M.round( getG(c)*15 ) )
			+ HEX_CHARS.charAt( M.round( getB(c)*15 ) );
	}

	/** Returns a 4-chars String using format "argb" (WARNING: color precision will be reduced!) */
	public static inline function intToHex3_ARGB(c:Int) : String {
		var h = StringTools.hex(c,8);
		return HEX_CHARS.charAt( M.round( getA(c)*15 ) )
			+ HEX_CHARS.charAt( M.round( getR(c)*15 ) )
			+ HEX_CHARS.charAt( M.round( getG(c)*15 ) )
			+ HEX_CHARS.charAt( M.round( getB(c)*15 ) );
	}

	/** Parse a 4-chars String using format "argb" (expanded to "aarrggbb") **/
	public static inline function hex3ToInt_ARGB(argbHex:String) : Int {
		if( argbHex==null )
			return 0x0;
		else if( argbHex.length==4 )
			return Lib.parseSignedInt(
				"0x"
				+ argbHex.charAt(0)+argbHex.charAt(0)
				+ argbHex.charAt(1)+argbHex.charAt(1)
				+ argbHex.charAt(2)+argbHex.charAt(2)
				+ argbHex.charAt(3)+argbHex.charAt(3)
			);
		else if( argbHex.length==3 )
			return Lib.parseSignedInt(
				"0xff"
				+ argbHex.charAt(0)+argbHex.charAt(0)
				+ argbHex.charAt(1)+argbHex.charAt(1)
				+ argbHex.charAt(2)+argbHex.charAt(2)
			);
		else
			return 0x0;
	}

	public static inline function intToRgb(c:Int) : Col {
		return {
			r	: (c>>16)&0xFF,
			g	: (c>>8)&0xFF,
			b	: c&0xFF,
		}
	}

	/** Get Alpha as 0-1 float from 0xaarrggbb **/
	public static inline function getA(c:Int) : Float return getAi(c)/255;

	/** Get Red as 0-1 float from 0x[aa]rrggbb **/
	public static inline function getR(c:Int) : Float return getRi(c)/255;

	/** Get Green as 0-1 float from 0x[aa]rrggbb **/
	public static inline function getG(c:Int) : Float return getGi(c)/255;

	/** Get Blue as 0-1 float from 0x[aa]rrggbb **/
	public static inline function getB(c:Int) : Float return getBi(c)/255;


	/** Get Alpha as 0-255 integer from 0xaarrggbb **/
	public static inline function getAi(c:Int) : Int return (c>>24)&0xFF;

	/** Get Red as 0-255 integer from 0x[aa]rrggbb **/
	public static inline function getRi(c:Int) : Int return (c>>16)&0xFF;

	/** Get Green as 0-255 integer from 0x[aa]rrggbb **/
	public static inline function getGi(c:Int) : Int return (c>>8)&0xFF;

	/** Get Blue as 0-255 integer from 0x[aa]rrggbb **/
	public static inline function getBi(c:Int) : Int return c&0xFF;


	#if( h3d || heaps )
	public static inline function intToVector(c:Int) : h3d.Vector {
		var c = intToRgb(c);
		return new h3d.Vector(c.r/255, c.g/255, c.b/255);
	}

	public static inline function setVector(v:h3d.Vector, c:UInt) {
		var c = intToRgb(c);
		v.r = c.r/255;
		v.g = c.g/255;
		v.b = c.b/255;
	}
	#end

	public static inline function intToRgba(c:Int) : Col32 {
		return {
			a	: Std.int( getA(c) * 255 ),
			r	: Std.int( getR(c) * 255 ),
			g	: Std.int( getG(c) * 255 ),
			b	: Std.int( getB(c) * 255 ),
		}
	}

	public static inline function intToHsl(c:Int) : ColHsl {
		return rgbToHsl( intToRgb(c) );
	}

	public static inline function rgbaToInt(c:Col32) : Int {
		return (c.a << 24) | (c.r<<16 ) | (c.g<<8) | c.b;
	}

	public static inline function rgbaToRgb(c:Col32) : Col {
		return { r:c.r, g:c.g, b:c.b };
	}

	public static inline function multiply(c:Col, f:Float) {
		return {
			r	: Std.int(c.r*f),
			g	: Std.int(c.g*f),
			b	: Std.int(c.b*f),
		}
	}

	public static function saturation(c:Col, delta:Float) {
		var hsl = rgbToHsl(c);
		hsl.s+=delta;
		if( hsl.s>1 ) hsl.s = 1;
		if( hsl.s<0 ) hsl.s = 0;
		return hslToRgb(hsl);
	}

	public static inline function saturationInt(c:Int, delta:Float) {
		return rgbToInt( saturation(intToRgb(c), delta) );
	}

	public static function clampBrightness(c:Col, minLum:Float, maxLum:Float) : Col {
		var hsl = rgbToHsl(c);
		if( hsl.l>maxLum ) {
			hsl.l = maxLum;
			return hslToRgb(hsl);
		}
		else if( hsl.l<minLum ) {
			hsl.l = minLum;
			return hslToRgb(hsl);
		}
		else
			return c;
	}

	public static function clampBrightnessInt(cint:Int, minLum:Float, maxLum:Float) : Int {
		var hsl = intToHsl(cint);
		if( hsl.l>maxLum ) {
			hsl.l = maxLum;
			return hslStructToInt(hsl);
		}
		else if( hsl.l<minLum ) {
			hsl.l = minLum;
			return hslStructToInt(hsl);
		}
		else
			return cint;
	}

	public static function cap(c:Col, sat:Float, lum:Float) {
		var hsl = rgbToHsl(c);
		if( hsl.s>sat ) hsl.s = sat;
		if( hsl.l>lum ) hsl.l = lum;
		return hslToRgb(hsl);
	}

	public static function capInt(c:Int, sat:Float, lum:Float) {
		var hsl = intToHsl(c);
		if( hsl.s>sat ) hsl.s = sat;
		if( hsl.l>lum ) hsl.l = lum;
		return hslStructToInt(hsl);
	}

	public static function hue(c:Col, f:Float) {
		var hsl = rgbToHsl(c);
		hsl.h+=f;
		if( hsl.h>1 ) hsl.h = 1;
		if( hsl.h<0 ) hsl.h = 0;
		return hslToRgb(hsl);
	}

	public static inline function getHue(c:Int) {
		return intToHsl(c).h;
	}

	public static inline function getSaturation(c:Int) {
		return intToHsl(c).s;
	}

	public static inline function hueInt(c:Int, f:Float) {
		return rgbToInt( hue(intToRgb(c), f) );
	}

	public static function change(cint:Int, ?lum:Null<Float>, ?sat:Null<Float>) {
		var hsl = intToHsl(cint);

		if( lum!=null )
			hsl.l = lum;

		if( sat!=null )
			hsl.s = sat;

		return hslStructToInt(hsl);
	}

	public static function brightnessInt(cint:Int, delta:Float) {
		return rgbToInt( brightness( intToRgb(cint), delta ) );
	}
	public static function brightness(c:Col, delta:Float) {
		var hsl = rgbToHsl(c);
		if( delta<0 ) {
			// Darken
			hsl.l+=delta;
			if( hsl.l<0 ) hsl.l = 0;
		}
		else {
			// Brighten
			var d = 1-hsl.l;
			if( d>delta )
				hsl.l += delta;
			else {
				hsl.l = 1;
				hsl.s -= delta-d;
				if( hsl.s<0 ) hsl.s = 0;
			}
		}
		return hslToRgb(hsl);
	}


	public static inline function grayscale(c:UInt) : UInt {
		var gray = getGrayscaleFactor(c);
		return
			( Std.int(gray*255) << 16 ) |
			( Std.int(gray*255) << 8 ) |
			( Std.int(gray*255) );
	}

	public static inline function getGrayscaleFactor(c:UInt) : Float {
		return RED_LUMA*getR(c) + GREEN_LUMA*getG(c) + BLUE_LUMA*getB(c);
	}


	public static inline function getAlpha(c:Int) : #if (flash || openfl) UInt #else Int #end {
		return c>>>24;
	}

	public static inline function getAlphaF(c:Int) : Float {
		return (c>>>24) / 255.0;
	}

	public static inline function hasAlpha(c:Int) : Bool {
		return ( c>>>24 ) > 0;
	}

	public static inline function removeAlpha(col32:UInt) : UInt {
		return col32 & 0xffffff;
	}

	public static inline function replaceAlphaF(c:Int, ?a=1.0) : #if (flash || openfl) UInt #else Int #end {
		return addAlphaF( removeAlpha(c), a );
	}

	public static inline function addAlphaF(c:Int, ?a=1.0) : UInt {
		return Std.int(a*255)<<24 | c;
	}
	public static inline function addAlphaI(c:Int, ?a=255) : UInt {
		return a<<24 | c;
	}

	public static inline function randomColor(?hue:Float, sat=1.0, lum=1.0) {
		return makeColorHsl(hue==null ? Math.random() : hue, sat, lum);
	}

	public static inline function fromString(k:String) {
		if( k==null )
			return 0x999999;
		var csum = 0;
		for(i in 0...k.length) csum+=k.charCodeAt(i);
		return makeColorHsl( (csum%1000)/1000, 0.5+0.5*(csum%637)/637, 0.6+0.4*(csum%1221)/1221 );
	}

	public static inline function fromStringLight(k:String) {
		if( k==null )
			return 0xffffff;
		var csum = 0;
		for(i in 0...k.length) csum+=k.charCodeAt(i);
		return makeColorHsl( (csum%100)/100, 0.3+0.3*(csum%210)/210, 1 );
	}


	/** Init the "unique" color palette used by `pickUniqueColorFor()` **/
	static var uniqueColors : Array<UInt> = [];
	public static function initUniqueColors(count=12, ?mixedColor:Null<Int>, mixIntensity=0.5) {
		assignedUniqueColors = new Map();

		// Init palette
		uniqueColors = [];
		for(i in 0...count) {
			var hue = i/count;
			hue = Math.pow(hue, 1.5);
			var sat = (0.6+0.4*(1-hue)) * ( i%2==0 ? 1 : 0.6 ) ;
			var lum = i%2==0 ? 1 : 0.6;
			var c = makeColorHsl(hue, sat, lum);
			if( mixedColor!=null )
				c = interpolateInt(c, mixedColor, mixIntensity);
			uniqueColors.push(c);
		}

		var rseed = new dn.Rand(197);
		dn.Lib.shuffleArray(uniqueColors, rseed.random);
	}

	/** Pick a random color based on a string. Try to avoid color repetitions, as long as the "unique" colors palette isn't depleted. **/
	static var assignedUniqueColors : Map<Int,String> = new Map();
	public static function pickUniqueColorFor(str:String) {
		if( uniqueColors.length==0 )
			initUniqueColors();

		// Build string "kind-of checksum"
		var csum = 0;
		for(i in 0...str.length)
			csum += str.charCodeAt(i) - 31;
		var idx = csum % uniqueColors.length;

		if( !assignedUniqueColors.exists(idx) ) {
			// Unused unique color index
			assignedUniqueColors.set(idx,str);
		}
		else if( assignedUniqueColors.get(idx)!=str ) {
			// Color index in use, but by another string
			var limit = uniqueColors.length;
			while( limit-->0 && assignedUniqueColors.exists(idx) && assignedUniqueColors.get(idx)!=str ) {
				idx++;
				if( idx>=uniqueColors.length )
					idx = 0;
			}
			if( limit<=0 ) {
				// Palette limit exceeded, use default index
				idx = csum % uniqueColors.length;
			}
			else {
				// Self-assign the unused index found
				assignedUniqueColors.set(idx,str);
			}
		}

		return uniqueColors[idx];
	}

	public static inline function makeColorHsl(hue:Float, ?saturation=1.0, ?luminosity=1.0) : Int { // range : 0-1
		return hslToInt(hue,saturation,luminosity);
	}

	@:noCompletion
	@:deprecated("Please use makeColorArgb instead")
	public static inline function makeColor(r:Float, g:Float, b:Float, a=1.0) : UInt { // range : 0-1
		return makeColorArgb(r,g,b,a);
	}

	@:noCompletion
	@:deprecated("Please use makeColorArgb instead")
	public static inline function makeColorRgba(r:Float, g:Float, b:Float, a=1.0) : UInt {
		return makeColorArgb(r,g,b,a);
	}

	public static inline function makeColorRgb(r:Float, g:Float, b:Float) : UInt { // range : 0-1
		return
			( Std.int(r*255) << 16)
			| ( Std.int(g*255) << 8 )
			| Std.int(b*255);
		// return rgbaToInt({ r:Std.int(r*255), g:Std.int(g*255), b:Std.int(b*255), a:Std.int(a*255) });
	}


	public static inline function makeColorArgb(r:Float, g:Float, b:Float, a=1.0) : UInt { // range : 0-1
		return
			( Std.int(a*255) << 24)
			| ( Std.int(r*255) << 16)
			| ( Std.int(g*255) << 8 )
			| Std.int(b*255);
		// return rgbaToInt({ r:Std.int(r*255), g:Std.int(g*255), b:Std.int(b*255), a:Std.int(a*255) });
	}

	public static inline function getRgbRatio(?cint:Int, ?crgb:Col) {
		var c = cint!=null ? intToRgb(cint) : crgb;
		//var max = rgb.r>rgb.g ? (rgb.r>rgb.b ? rgb.r : rgb.b)
		var max =
			if( c.b>c.g && c.b>c.r ) c.b;
			else if( c.g>c.r && c.g>c.b ) c.g;
			else c.r;
		return { r:c.r/max, g:c.g/max, b:c.b/max }
		//return rgb.r<=maxRed*255 && rgb.g<=maxGreen*255 && rgb.b<=maxBlue*255;
	}

	public static inline function getPerceivedLuminosity(c:Col) : Float  { // 0-1
		return Math.sqrt( RED_LUMA*(c.r*c.r) + GREEN_LUMA*(c.g*c.g) + BLUE_LUMA*(c.b*c.b) ) / 255;
	}

	public static inline function getPerceivedLuminosityInt(c:UInt) : Float { // 0-1
		return Math.sqrt( RED_LUMA*(getR(c)*getR(c)) + GREEN_LUMA*(getG(c)*getG(c)) + BLUE_LUMA*(getB(c)*getB(c)) );
	}

	public static inline function autoContrast(c:Int, ?ifLight=0x0, ?ifDark=0xffffff) { // returns ifLight color if c is light, ifDark otherwise
		return getPerceivedLuminosityInt(c)>=0.5 ? ifLight : ifDark;
	}

	public static inline function autoContrastCustom(c:Int, lumiThreshold:Float, ?ifLight=0x0, ?ifDark=0xffffff) { // returns ifLight color if c is light, ifDark otherwise
		return getPerceivedLuminosityInt(c)>=lumiThreshold ? ifLight : ifDark;
	}

	public static inline function getLuminosity(?c:Col, ?cint:Int) { // 0-1, valeur HSL
		return ( c!=null ) ? rgbToHsl(c).l : intToHsl(cint).l;
	}

	public static inline function setLuminosity(c:Col, lum:Float) {
		var hsl = rgbToHsl(c);
		hsl.l = lum;
		return hslToRgb(hsl);
	}

	public static inline function setSL(c:UInt, sat:Float, lum:Float) {
		var hsl = intToHsl(c);
		hsl.s = sat;
		hsl.l = lum;
		return hslStructToInt(hsl);
	}

	public static inline function changeHslInt(c:Int, lum:Float, sat:Float) {
		var hsl = intToHsl(c);
		hsl.l = lum;
		hsl.s = sat;
		return hslStructToInt(hsl);
	}

	public static inline function addHslInt(c:Int, hDelta:Float, sDelta:Float, lDelta:Float) {
		var hsl = intToHsl(c);
		hsl.h = M.fclamp( hsl.h + hDelta, 0, 1 );
		hsl.s = M.fclamp( hsl.s + sDelta, 0, 1 );
		hsl.l = M.fclamp( hsl.l + lDelta, 0, 1 );
		return hslStructToInt(hsl);
	}

	public static inline function setLuminosityInt(c:Int, lum:Float) {
		var hsl = intToHsl(c);
		hsl.l = lum;
		return hslStructToInt(hsl);
	}

	public static inline function offsetColor(c:Col, delta:Int) : Col {
		return {
			r	: Std.int( M.fmax(0, M.fmin(255,c.r + delta)) ),
			g	: Std.int( M.fmax(0, M.fmin(255,c.g + delta)) ),
			b	: Std.int( M.fmax(0, M.fmin(255,c.b + delta)) ),
		}
	}
	public static inline function offsetColorRgba(c:Col32, delta:Int) : Col32 {
		return {
			r	: Std.int( M.fmax(0, M.fmin(255,c.r + delta)) ),
			g	: Std.int( M.fmax(0, M.fmin(255,c.g + delta)) ),
			b	: Std.int( M.fmax(0, M.fmin(255,c.b + delta)) ),
			a	: c.a,
		}
	}
	public static inline function offsetColorInt(c:Int, delta:Int) : Int {
		return rgbToInt( offsetColor(intToRgb(c), delta) );
	}

	public static inline function interpolatePal(from:Pal, to:Pal, ratio:Float) : Pal {
		var result : Pal = new Array();
		for (i in 0...from.length)
			result[i] = interpolate(from[i], to[i], ratio);
		return result;
	}

	public static inline function interpolate(from:Col, to:Col, ratio:Float) : Col {
		ratio = M.fclamp(ratio,0,1);
		return {
			r	: Std.int( from.r + (to.r-from.r)*ratio ),
			g	: Std.int( from.g + (to.g-from.g)*ratio ),
			b	: Std.int( from.b + (to.b-from.b)*ratio ),
		}
	}

	public static inline function interpolateInt(from:Int, to:Int, ratio:Float) : Int {
		return
			( M.round( 255 * M.lerp( getA(from), getA(to), ratio ) ) << 24 ) |
			( M.round( 255 * M.lerp( getR(from), getR(to), ratio ) ) << 16 ) |
			( M.round( 255 * M.lerp( getG(from), getG(to), ratio ) ) << 8 ) |
			( M.round( 255 * M.lerp( getB(from), getB(to), ratio ) ) );
	}

	public static inline function mix<T>(from:T, to:T, ratio:Float) {
		switch( Type.typeof(from) ) {
			case TInt : return cast interpolateInt(cast from, cast to, ratio);
			case TObject : return cast interpolate(cast from, cast to, ratio);
			default : throw "error";
		}
	}

	public static function average(a:Array<Int>) : Int {
		if( a.length==0 )
			return 0x0;
		var c = a[0];
		for(i in 1...a.length)
			c = interpolateInt(c, a[i], 0.5);
		return c;
	}

	public static inline function interpolateIntArray(colors:Array<Int>, ratio:Float) : Int {
		if( colors.length<2 )
			throw "Need 2 colors or more!";

		ratio = M.fclamp(ratio, 0,1);
		var idx = Std.int(ratio*(colors.length-1));
		var segLen = 1/(colors.length-1);
		var subRatio = (ratio-segLen*idx) / segLen;
		return rgbToInt( interpolate(intToRgb(colors[idx]), intToRgb(colors[idx+1]), subRatio) );
	}

	public static inline function toBlack(c:Int, ratio:Float) : Int {
		return interpolateInt(c, addAlphaF(0x0, getA(c)), ratio);
	}

	public static inline function toWhite(c:Int, ratio:Float) : Int {
		return interpolateInt(c, addAlphaF(0xffffff, getA(c)), ratio);
	}



	public static function getPaletteAverage(pal:Pal):Col {
		if (pal.length<0)
			return Reflect.copy(BLACK);
		var c = {r:0, g:0, b:0};
		for (p in pal) {
			c.r+=p.r;
			c.g+=p.g;
			c.b+=p.b;
		}
		return {
			r : Std.int(c.r/pal.length),
			g : Std.int(c.g/pal.length),
			b : Std.int(c.b/pal.length),
		}
	}

	#if(h3d||heaps)
	public static inline function applyH2dContrast(e:h2d.Drawable, ratio:Float) {
		var m = 1+ratio*1.5;
		var o = -0.25*ratio;
		e.colorMatrix = h3d.Matrix.L([
			m,0,0,0,
			0,m,0,0,
			0,0,m,0,
			0,0,0,1,
		]);
		e.colorAdd = new h3d.Vector(o,o,o,0);
	}

	public static inline function uncolorizeBatchElement(e:h2d.SpriteBatch.BatchElement) {
		e.r = e.g = e.b = 1;
	}

	public static inline function colorizeBatchElement(e:h2d.SpriteBatch.BatchElement, c:UInt, ratio=1.0) {
		e.r = M.lerp( 0xffffff, getR(c), ratio );
		e.g = M.lerp( 0xffffff, getG(c), ratio );
		e.b = M.lerp( 0xffffff, getB(c), ratio );
		// e.r = interpolateR(0xFFFFFF, c, ratio) / 255;
		// e.g = interpolateG(0xFFFFFF, c, ratio) / 255;
		// e.b = interpolateB(0xFFFFFF, c, ratio) / 255;
	}
	#end

	#if (flash9 || openfl)
	public static inline function getDarkenCT(ratio:Float) {
		var ct = new flash.geom.ColorTransform();
		ct.redMultiplier = ct.greenMultiplier = ct.blueMultiplier = 1-ratio;
		return ct;
	}

	public static inline function getSimpleCT(?col:Col, ?colInt:Int, ?alpha:Null<Float>) {
		if (col==null)
			col = intToRgb(colInt);
		var ct = new flash.geom.ColorTransform();
		ct.redOffset = col.r-127;
		ct.greenOffset = col.g-127;
		ct.blueOffset = col.b-127;
		if(alpha!=null)
			ct.alphaMultiplier = alpha;
		return ct;
	}
	public static inline function getColorizeCT(?col:Col, ?colInt:Int, ratio:Float) {
		if (col==null)
			col = intToRgb(colInt);
		var ct = new flash.geom.ColorTransform();
		ct.redOffset = col.r*ratio;
		ct.greenOffset = col.g*ratio;
		ct.blueOffset = col.b*ratio;
		ct.redMultiplier = 1-ratio;
		ct.greenMultiplier = 1-ratio;
		ct.blueMultiplier = 1-ratio;
		return ct;
	}


	public static inline function getBrightnessFilter(ratio:Float) : flash.filters.ColorMatrixFilter { // -1 -> 1
		var r = 1+ratio;
		var matrix = [
			r,0,0,0, 0,
			0,r,0,0, 0,
			0,0,r,0, 0,
			0,0,0,1, 0,
		];
		return new flash.filters.ColorMatrixFilter(matrix);
	}

	public static inline function getContrastFilter(ratio:Float) : flash.filters.ColorMatrixFilter { // -1 -> 1
		var m = 1+ratio*1.5;
		var o = -64*ratio;
		var matrix = [
			m,0,0,0,o,
			0,m,0,0,o,
			0,0,m,0,o,
			0,0,0,1,0,
		];
		return new flash.filters.ColorMatrixFilter(matrix);
	}


	// Renvoie une matrice pour utiliser avec un ColorMatrixFilter
	static inline function getDesaturateMatrix(?ratio=1.0) {
		// Credit : https://en.wikipedia.org/wiki/Luma_(video)
		var redIdentity		= [1.0, 0, 0, 0, 0];
		var greenIdentity	= [0, 1.0, 0, 0, 0];
		var blueIdentity	= [0, 0, 1.0, 0, 0];
		var alphaIdentity	= [0, 0, 0, 1.0, 0];
		var grayluma		= [RED_LUMA, GREEN_LUMA, BLUE_LUMA, 0, 0];

		var a = new Array();
		a = a.concat( interpolateArrays(redIdentity,	grayluma, ratio) );
		a = a.concat( interpolateArrays(greenIdentity,	grayluma, ratio) );
		a = a.concat( interpolateArrays(blueIdentity,	grayluma, ratio) );
		a = a.concat( alphaIdentity );
		return a;
	}

	public static inline function getSaturationFilter(ratio:Float) : flash.filters.ColorMatrixFilter { // -1 -> 1
		var matrix =
			if(ratio>0)
			[
				1+ratio,-ratio,0,0,0,
				-ratio,1+ratio,0,0,0,
				0,-ratio,1+ratio,0,0,
				0,0,0,1,0,
			];
			else
				getDesaturateMatrix(-ratio);
		return new flash.filters.ColorMatrixFilter(matrix);
	}

	public static inline function getInterpolatedCT(colFrom:Col, colTo:Col, ratio:Float) {
		return getSimpleCT( interpolate(colFrom, colTo, ratio) );
	}
	#end



	#if( h3d || heaps )
	public static inline function getColorizeMatrixH2d(col:Int, ?ratioNewColor=1.0, ?ratioOldColor:Float) {
		if( ratioOldColor==null )
			ratioOldColor = 1-ratioNewColor;
		var rgb = intToRgb(col);
		var r = ratioNewColor * rgb.r/255;
		var g = ratioNewColor * rgb.g/255;
		var b = ratioNewColor * rgb.b/255;
		var m = [
			ratioOldColor+r, g, b, 0,
			r, ratioOldColor+g, b, 0,
			r, g, ratioOldColor+b, 0,
			0, 0, 0, 1,
		];
		return h3d.Matrix.L(m);
	}

	public static inline function getColorizeFilterH2d(col:UInt, ?ratioNewColor=1.0, ?ratioOldColor:Float) : h2d.filter.ColorMatrix {
		return new h2d.filter.ColorMatrix( getColorizeMatrixH2d(col, ratioNewColor, ratioOldColor) );
	}
	#end

	#if (flash9 || openfl)
	public static inline function getColorizeFilter(col:Int, ?ratioNewColor=1.0, ?ratioOldColor=1.0) {
		var rgb = intToRgb(col);
		var r = ratioNewColor * rgb.r/255;
		var g = ratioNewColor * rgb.g/255;
		var b = ratioNewColor * rgb.b/255;
		var m = [
			ratioOldColor+r, r, r, 0, 0,
			g, ratioOldColor+g, g, 0, 0,
			b, b, ratioOldColor+b, 0, 0,
			0, 0, 0, 1.0, 0,
		];
		return new flash.filters.ColorMatrixFilter(m);
	}
	#end


	#if (flash9 || openfl)
	public static inline function getGammaFilter(ratio:Float) { // not exactly a gamma
		var matrix = [
			1+ratio, 0, 0, 0, 0,
			0, 1+ratio, 0, 0, 0,
			0, 0, 1+ratio, 0, 0,
			0, 0, 0, 1, 0,
		];
		return new flash.filters.ColorMatrixFilter(matrix);
	}
	#end

	private static inline function interpolateArrays(ary1:Array<Float>, ary2:Array<Float>, t:Float){
		// Credit : http://www.senocular.com/flash/source/?id=0.169
		var result = new Array();
		for (i in 0...ary1.length)
			result[i] = ary1[i] + (ary2[i] - ary1[i])*t;
		return result;
	}

	#if ((flash9) )//&& (!openfl))
	public static inline function replaceChannel(bd:flash.display.BitmapData, r:Bool, g:Bool, b:Bool, colInt:Int, ?brightness=1.5) {
		var pt = new flash.geom.Point(0,0);
		var r_chan = if (r) extractChannel( bd, r, false, false ) else null;
		var g_chan = if (g) extractChannel( bd, false, g, false ) else null;
		var b_chan = if (b) extractChannel( bd, false, false, b ) else null;

		var diff : flash.display.BitmapData = null;

		var fl_2channels = r && g || r && b || g && b;

		if (fl_2channels) {
			// remplacement avec 2 channels
			diff = extractChannel( bd, r, g, b );
			if (r)	compareBitmaps(diff, r_chan);
			if (g)	compareBitmaps(diff, g_chan);
			if (b)	compareBitmaps(diff, b_chan);
		}
		else {
			// remplacemetn avec 1 seul channel
			if (r) diff = r_chan;
			if (g) diff = g_chan;
			if (b) diff = b_chan;
		}

		// on remplace le canal demandé
		var col = intToRgb(colInt);
		var fact = if (fl_2channels) 0.5 else 1;
		var r_ratio = fact * col.r/255 * brightness;
		var g_ratio = fact * col.g/255 * brightness;
		var b_ratio = fact * col.b/255 * brightness;
		var rint = r?1:0;
		var gint = g?1:0;
		var bint = b?1:0;
		var matrix = [
			rint*r_ratio, gint*r_ratio, bint*r_ratio, 0,0,
			rint*g_ratio, gint*g_ratio, bint*g_ratio, 0,0,
			rint*b_ratio, gint*b_ratio, bint*b_ratio, 0,0,
			0,0,0,1,0,
		];
		diff.applyFilter(diff, diff.rect, pt,
			new flash.filters.ColorMatrixFilter(matrix));
		bd.draw(diff);

		if(r_chan!=null) r_chan.dispose();
		if(g_chan!=null) g_chan.dispose();
		if(b_chan!=null) b_chan.dispose();
		diff.dispose();
	}

	//#if !openfl
	private static inline function extractChannel(bd:flash.display.BitmapData, r:Bool, g:Bool, b:Bool) {
		var chan = bd.clone();
		var mask : Col32 = { a:0, r:(r?0:1)*255, g:(g?0:1)*255, b:(b?0:1)*255 };
		chan.threshold(chan, chan.rect, new flash.geom.Point(0, 0),
			">", 0x00000000, 0x00000000, Color.rgbaToInt(mask));
		return chan;
	}
	//#end

	private static inline function compareBitmaps(target:flash.display.BitmapData, bd:flash.display.BitmapData) {
		var comp : Dynamic = target.compare(bd);
		target.fillRect(target.rect, 0x0);
		if (Type.typeof(comp)!=TInt) {
			target.fillRect(target.rect, 0x0);
			var comp : flash.display.BitmapData = comp;
			target.draw(comp);
			comp.dispose();
		}
	}

	public static inline function getChannelMask(r:Int,g:Int,b:Int) { // 0-1
		var c : Col32 = { a:0, r:r*255, g:g*255, b:b*255 }
		return rgbaToInt(c);
	}

	public static inline function makeNicePalette(col:Int, ?dark=0x0, ?light:Null<Int>, ?addAlpha=false) : PalInt {
		var col = intToRgb(col);
		if (light==null)
			light = rgbToInt( offsetColor(col, 100) );
		var dark = intToRgb(dark);
		var light = intToRgb(light);
		var pal : PalInt = new Array();
		var lightLimit = 200;
		var lightRange = 256-lightLimit;
		for (i in 0...256) {
			if (i<lightLimit)
				pal[i] = rgbToInt( interpolate(dark, col, i/lightLimit) );
			else
				pal[i] = rgbToInt( interpolate(col, light, (i-lightLimit)/lightRange) );
			//pal[i] = rgbToInt( interpolate(dark, col, i/255) );
			if (addAlpha)
				pal[i] = 0xff<<24 | pal[i];
		}
		return pal;
	}

	public static inline function makePaletteLinear(colors:Array<Int>, ?len=256) : PalInt { // du sombre au clair
		var pal : PalInt = [];
		var stepLength = len/(colors.length-1);
		for (i in 0...len) {
			var step = i/stepLength;
			var col0 = colors[Std.int(step)];
			var col1 = colors[Std.int(step)+1];
			pal[i] = interpolateInt(col0, col1, step-Std.int(step));
		}
		return pal;
	}

	public static inline function makePaletteCustom(colors:Array<{ratio:Float, col:Int}>) : PalInt { // du sombre au clair
		if( colors.length<2 )
			return throw "makePaletteCustom: not enough colors";

		var pal : PalInt = [];
		var idx = 0;
		var colors = colors.map( function(c) return {idx:M.round(c.ratio*256), col:c.col} );
		colors.sort(function(a,b) return Reflect.compare(a.idx, b.idx));
		if( colors[0].idx!=0 )
			colors.insert(0, {idx:0, col:colors[0].col});

		if( colors[colors.length-1].idx!=256 )
			colors.push({ idx:256, col:colors[colors.length-1].col });

		var cidx = 0;
		do {
			var from = colors[cidx];
			var to = colors[cidx+1];
			var subPal = makePaletteLinear([from.col, to.col], to.idx-from.idx);
			pal = pal.concat(subPal);
			cidx++;
		} while( cidx+1<colors.length );
		return pal;
	}


	#if( h3d || heaps )
	public static function makeWhiteGradient(wid,hei, light:UInt, dark:UInt, ?white:UInt) : h3d.mat.Texture {
		var p = hxd.Pixels.alloc(wid,hei, ARGB);
		var white = white!=null ? white : Color.brightnessInt(light, 0.5);
		var pal = Color.makeNicePalette(light, dark, white, true);
		for(x in 0...wid)
			for(y in 0...hei)
				p.setPixel(x, y, pal[M.round(pal.length*x/wid)]);

		return h3d.mat.Texture.fromPixels(p);
	}

	public static function makeLinearGradient(wid, hei, light:UInt, dark:UInt) : h3d.mat.Texture {
		var p = hxd.Pixels.alloc(wid,hei, ARGB);
		var pal = Color.makePaletteLinear([light,dark], 256);
		for(x in 0...wid)
			for(y in 0...hei)
				p.setPixel(x, y, pal[M.round(pal.length*x/wid)]);

		return h3d.mat.Texture.fromPixels(p);
	}
	#end




	#if (flash10 && color_lab)
	public static function getFastPalette(r:PalInt, g:PalInt, b:PalInt, yellow:PalInt, pink:PalInt, cyan:PalInt) {
		var ba = new flash.utils.ByteArray();
		for (i in 0...256)	ba.writeUnsignedInt(0xff000000|0x0); // canaux 0,0,0
		for (c in r)		ba.writeUnsignedInt(0xff000000|c);
		for	(c in g)		ba.writeUnsignedInt(0xff000000|c);
		for	(c in yellow)	ba.writeUnsignedInt(0xff000000|c);
		for	(c in b)		ba.writeUnsignedInt(0xff000000|c);
		for	(c in pink)		ba.writeUnsignedInt(0xff000000|c);
		for (c in cyan)		ba.writeUnsignedInt(0xff000000|c);
		for (i in 0...256)	ba.writeUnsignedInt(0x0); // canaux 1,1,1
		ba.position = 0;
		return ba;
	}


	public static function paintBitmapFast(bd:flash.display.BitmapData, pal:flash.utils.ByteArray) {
		var bounds = if (bd.transparent) bd.getColorBoundsRect(0xff000000, 0x00000000, false) else bd.rect;
		var buffer = bd.getPixels(bounds);
		var palAddr = buffer.position;
		buffer.writeBytes(pal);
		buffer.position = 0;
		flash.Memory.select(buffer);
		var pos : UInt = 0;
		var palLength = 256*4;
		while (pos<palAddr) {
			var a = flash.Memory.getByte(pos);
			if ( a == 0 ) { pos += 4; continue; }
			var r = flash.Memory.getByte(pos+1);
			var g = flash.Memory.getByte(pos+2);
			var b = flash.Memory.getByte(pos+3);
			var idx = ( ((r>0)?1:0) | ((g>0)?2:0) | ((b>0)?4:0) );
			flash.Memory.setI32(pos, (flash.Memory.getI32(palAddr + (((idx<<8) + (r | g | b)) << 2)) & 0xFFFFFF00) | a);
			pos+=4;
		}
		bd.setPixels(bounds, buffer);
	}
	#end

	#if (flash10 || openfl)
	public static function paintBitmap(bd:flash.display.BitmapData, red:PalInt, green:PalInt, blue:PalInt, ?yellow:PalInt, ?pink:PalInt, ?cyan:PalInt) {
		//var bounds = (bd.transparent ? bd.getColorBoundsRect(0xff000000, 0x00000000, false) : bd.rect);
		var bounds = bd.rect;
		var pixels = bd.getPixels(bounds);
		pixels.position = 0;
		if (pixels.bytesAvailable>0) {
			flash.Memory.select(pixels);

			var pos : UInt = 0;
			var max = pixels.bytesAvailable;
			while (pos<max) {
				if( flash.Memory.getByte(pos)>0 ) { // test alpha
					var r = flash.Memory.getByte(pos+1);
					var g = flash.Memory.getByte(pos+2);
					var b = flash.Memory.getByte(pos+3);

					if(r!=g || g!=b || r!=b) {
						var result =
							if (g==0 && b==0)		red[r];
							else if (r==0 && b==0)	green[g];
							else if (r==0 && g==0)	blue[b];
							else if (r!=0 && g!=0)	yellow[r];
							else if (r!=0 && b!=0)	pink[r];
							else if (g!=0 && b!=0)	cyan[g];
							else 0xff00ff;
						flash.Memory.setByte(pos+1, result>>16);
						flash.Memory.setByte(pos+2, result>>8);
						flash.Memory.setByte(pos+3, result);
					}
				}
				pos+=4;
			}
			bd.setPixels(bounds, pixels);
		}
	}
	#end

	#if (flash10 || openfl)
	public static function paintBitmapGrays(bd:flash.display.BitmapData, pal:PalInt) {
		var bounds = bd.rect;
		var pixels = bd.getPixels(bounds);
		pixels.position = 0;
		if (pixels.bytesAvailable>0) {
			flash.Memory.select(pixels);

			var pos : UInt = 0;
			var max = pixels.bytesAvailable;
			while (pos<max) {
				if( flash.Memory.getByte(pos)>0 ) { // test alpha
					var r = flash.Memory.getByte(pos+1);
					var g = flash.Memory.getByte(pos+2);
					var b = flash.Memory.getByte(pos+3);

					if(r==g && g==b) {
						var result = pal[r];
						flash.Memory.setByte(pos+1, result>>16);
						flash.Memory.setByte(pos+2, result>>8);
						flash.Memory.setByte(pos+3, result);
					}
				}
				pos+=4;
			}
			bd.setPixels(bounds, pixels);
		}
	}
	#end


	public static function pickColor(bd:flash.display.BitmapData, rect:flash.geom.Rectangle) : Col32 {
		var ba = bd.getPixels(rect);
		var sum = {a:0., r:0., g:0., b:0.}
		var pos = 0;
		var len : Int = ba.length;
		while( pos < len ) {
			sum.a += ba[pos++];
			sum.r += ba[pos++];
			sum.g += ba[pos++];
			sum.b += ba[pos++];
		}
		var n = rect.width*rect.height;
		var rgba : Col32 = {a:Std.int(sum.a/n), r:Std.int(sum.r/n), g:Std.int(sum.g/n), b:Std.int(sum.b/n)}
		return {a:Std.int(sum.a/n), r:Std.int(sum.r/n), g:Std.int(sum.g/n), b:Std.int(sum.b/n)}
	}

	public static function drawPalette(g:flash.display.Graphics, ?wid=32, ?hei=32, ?aint:Array<Int>, ?acol:Array<Col>) {
		if( aint!=null )
			for(i in 0...aint.length) {
				g.beginFill(aint[i], 1);
				g.drawRect(i*wid, 0, wid,hei);
				g.endFill();
			}
		else
			for(i in 0...acol.length) {
				g.beginFill(rgbToInt(acol[i]), 1);
				g.drawRect(i*wid, 0, wid,hei);
				g.endFill();
			}
	}
	#end // Fin IF FLASH9


	@:noCompletion
	public static function __test() {
		// String Hex
		CiAssert.equals( intToHex(0xff00ff), "#FF00FF" );
		CiAssert.equals( hexToInt("#ff00ff"), 0xff00ff );
		CiAssert.isTrue( isValidHex("#ff00ff") );
		CiAssert.isFalse( isValidHex("#zff00ff") );
		CiAssert.isFalse( isValidHex("#gf00ff") );
		CiAssert.equals( sanitizeHexStr("#fc0"), "#ffcc00" );
		CiAssert.equals( sanitizeHexStr("#a"), "#aaaaaa" );
		CiAssert.equals( sanitizeHexStr("  #fc0 "), "#ffcc00" );
		CiAssert.equals( sanitizeHexStr("#gf00ff"), null );
		CiAssert.equals( intToHex3(0xffcc00), "fc0" );
		CiAssert.equals( intToHex3(0xDfCf0f), "dc1" );
		CiAssert.equals( intToHex3_ARGB(0xaaffcc00), "afc0" );
		CiAssert.equals( intToHex3_ARGB(0xffcc00), "0fc0" );
		CiAssert.equals( hex3ToInt_ARGB("afc0"), 0xaaffcc00 );
		CiAssert.equals( hex3ToInt_ARGB("fc0"), 0xffffcc00 );
		CiAssert.equals( intToHexARGB(0x11223344), "#11223344" );
		CiAssert.equals( intToHexRGBA(0x11223344), "#22334411" );

		// Channel getters
		CiAssert.equals( getR(0xff0000), 1 );
		CiAssert.equals( getR(0x330000), 0.2 );
		CiAssert.equals( getG(0x00ff00), 1 );
		CiAssert.equals( getB(0x0000ff), 1 );
		CiAssert.equals( getA(0xff00ff), 0 );
		CiAssert.equals( getA(0xffff00ff), 1 );
		CiAssert.equals( getA(0x33ff0080), 0.2 );
		CiAssert.equals( getAi(0x33ff0080), 51 );
		CiAssert.equals( getRi(0x33ff0080), 255 );
		CiAssert.equals( getGi(0x33ff0080), 0 );
		CiAssert.equals( getBi(0x33ff0080), 128 );

		// HSL
		CiAssert.equals( intToHsl(0xff0000).h, 0 );
		CiAssert.equals( intToHsl(0xff0000).s, 1 );
		CiAssert.equals( intToHsl(0xff0000).l, 1 );
		CiAssert.equals( hslToInt(0,1,1), 0xff0000 );
		CiAssert.equals( hslToInt(0,0,1), 0xffffff );
		CiAssert.equals( hslToInt(0.5,1,1), 0x00ffff );
		CiAssert.equals( getSaturation(0xff0000), 1 );

		// Make color
		CiAssert.equals( makeColorHsl(0, 1, 1), 0xff0000 );
		CiAssert.equals( makeColorRgb(1, 0, 0), 0xff0000 );
		CiAssert.equals( makeColorRgb(0, 1, 0), 0x00ff00 );
		CiAssert.equals( makeColorRgb(0, 0, 1), 0x0000ff );
		CiAssert.equals( makeColorArgb(0, 0, 0, 1), 0xff000000 );
		CiAssert.equals( makeColorArgb(0, 0.5, 0, 1), 0xff007f00 );

		// Luminosity
		CiAssert.equals( getLuminosity(0xffffff), 1 );
		CiAssert.equals( getLuminosity(0x00ff00), 1 );

		// Alpha
		CiAssert.equals( hasAlpha(0xaa112233), true );
		CiAssert.equals( hasAlpha(0x112233), false );

		// Transforms
		CiAssert.equals( interpolateInt(0x0, 0xffffff, 0), 0x0 );
		CiAssert.equals( interpolateInt(0x0, 0xffffff, 0.5), 0x808080 );
		CiAssert.equals( interpolateInt(0x0, 0xffffff, 1), 0xffffff );
		CiAssert.equals( interpolateInt(0xaa000000, 0xaaffffff, 0.5), 0xaa808080 );

		CiAssert.equals( toWhite(0x112233, 1), 0xffffff );
		CiAssert.equals( toWhite(0xaa112233, 1), 0xaaffffff );
		CiAssert.equals( toWhite(0xaa112233, 0), 0xaa112233 );
		CiAssert.equals( toWhite(0x000000, 0.5), 0x808080);
		CiAssert.equals( toWhite(0xaa000000, 0.5), 0xaa808080);

		CiAssert.equals( toBlack(0x112233, 1), 0x0 );
		CiAssert.equals( toBlack(0xaa112233, 1), 0xaa000000 );
		CiAssert.equals( toBlack(0xaa112233, 0), 0xaa112233 );
		CiAssert.equals( toBlack(0xffffff, 0.5), 0x808080);
		CiAssert.equals( toBlack(0xaaffffff, 0.5), 0xaa808080);
	}
}

