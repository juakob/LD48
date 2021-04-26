package dn.heaps.filter;

private enum AffectedLuminanceRange {
	Full; // Default
	OnlyLights;
	OnlyShadows;
}

/**
	Recolorize an object using the palette provided in a gradient texture.
**/
class GradientMap extends h2d.filter.Shader<InternalShader> {
	/** Y pixel coord of the palette in gradient map texture, default=0 **/
	public var paletteY: Int = 0;

	/** Gradient map intensity (0-1) **/
	public var intensity(default,set) : Float;
		inline function set_intensity(v) return shader.intensity = M.fclamp(v,0,1);

	/**
		@param gradientMap This texture is expected to be a **linear horizontal** color gradient, where left is darkest map color, and right is lightest color. If you have multiple palettes in a single texture, use `paletteY` instance field.
		@param intensity Gradient map intensity factor (0-1)
		@param mode Determine which range of luminance should be affected: Full (default), OnlyLights, OnlyShadows.
	**/
	public function new(gradientMap:h3d.mat.Texture, mode:AffectedLuminanceRange = Full, intensity=1.0) {
		super( new InternalShader() );

		shader.gradientMap = gradientMap;
		shader.mode = mode.getIndex();
		this.intensity = intensity;
	}

	override function draw(ctx:h2d.RenderContext, t:h2d.Tile):h2d.Tile {
		shader.paletteY = M.fclamp( paletteY * 1/t.height, 0, 1 );
		return super.draw(ctx, t);
	}

}


// --- Shader -------------------------------------------------------------------------------
private class InternalShader extends h3d.shader.ScreenShader {
	static var SRC = {
		@param var texture : Sampler2D;
		@param var gradientMap : Sampler2D;
		@const var mode : Int;
		@param var intensity : Float;
		@param var paletteY: Float = 0;

		inline function getLum(col:Vec3) : Float {
			return col.rgb.dot( vec3(0.2126, 0.7152, 0.0722) );
		}

		function fragment() {
			var pixel : Vec4 = texture.get(calculatedUV);

			if( intensity>0 ) {
				var lum = getLum(pixel.rgb);
				var rep = gradientMap.get( vec2(lum, paletteY) );

				if( mode==0 ) // Full gradient map
					pixelColor = vec4( mix(pixel.rgb, rep.rgb, intensity ), pixel.a);
				else if( mode==1 ) // Only lights
					pixelColor = vec4( mix(pixel.rgb, rep.rgb, intensity*lum ), pixel.a);
				else // Only shadows
					pixelColor = vec4( mix(pixel.rgb, rep.rgb, intensity*(1-lum) ), pixel.a);
			}
			else
				pixelColor = pixel;

		}
	};
}
