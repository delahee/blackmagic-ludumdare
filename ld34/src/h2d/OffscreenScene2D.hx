package h2d;

class OffscreenScene2D extends h2d.Scene {
	var wantedWith : Int;
	var wantedHeight : Int;
	var targetTile:h2d.Tile;
	
	public var targetDisplay : h2d.Bitmap;
	public var s2d : h2d.Scene;
	
	public var targetRatioW = 1.0;
	public var targetRatioH = 1.0;
	
	public var deferScene = true;
	
	static var uid = 0;
	var id = 0;
	
	public var hue : Float = 0.0;
	public var sat : Float = 1.0;
	public var brightness : Float = 0.0;
	public var contrast : Float = 0.0;
	
	var colorMatrix : h3d.Matrix = new h3d.Matrix();
	public var colorCorrection = true;
	public var overlay : h2d.Tile;
	public function new(w,h) {
		super();
		wantedWith = w;
		wantedHeight = h;
		id=++uid;
		name="Os2D #"+id;
	}
	
	function rescale2d() {
		for ( p in extraPasses) {
			var sc : h2d.Scene = Std.instance( p , h2d.Scene);
			if ( sc != null )
				sc.setFixedSize( wantedWith, wantedHeight);
		}
	}
	
	public override function render(engine:h3d.Engine) {
		colorMatrix.identity();
		colorMatrix.colorSaturation( sat );
		colorMatrix.colorHue( hue );
		colorMatrix.colorBrightness( brightness );
		colorMatrix.colorContrast( contrast );
		
		if ( s2d == null ) {
			s2d = new h2d.Scene();
			s2d.name="Os2D.s2d #"+id;
			if ( !deferScene )
				addPass(s2d);
		}
		
		s2d.checkEvents();
		
		if ( deferScene ) {
			targetTile = renderOffscreen(targetTile);
			
			if ( targetDisplay == null ) 
				targetDisplay = new h2d.Bitmap(targetTile, s2d);
			
			if( colorCorrection)
				targetDisplay.colorMatrix = colorMatrix
			else {
				if ( targetDisplay.colorMatrix != null)
					targetDisplay.colorMatrix = null;
			}
			
			if ( overlay != null){
				targetDisplay.alphaMap = overlay;
				targetDisplay.alphaMapAsOverlay = true;
			}
			s2d.render( engine );
		}
		else 
			super.render(engine);
	}
	
	public function renderOffscreen( target : h2d.Tile ) {
		var engine = h3d.Engine.getCurrent();
		var tw = hxd.Math.nextPow2(wantedWith);
		var th = hxd.Math.nextPow2(wantedHeight);
			
		if ( target == null ) {
			var tex = new h3d.mat.Texture(tw, th, h3d.mat.Texture.TargetFlag());
			target = new h2d.Tile(tex, 0, 0, tw, th);
			
			target.scaleToSize(wantedWith, wantedHeight);
			
			#if cpp 
			target.targetFlipY();
			#end
			
			targetRatioW = wantedWith / tw;
			targetRatioH = wantedWith / th;
		}
		
		var ow = engine.width;
		var oh = engine.height;
		
		rescale2d();
		
		var tx = target.getTexture();
		engine.setTarget(tx, true);
		engine.setRenderZone(target.x, target.y, tw, th);
		
		super.render(engine);
		
		posChanged = true;
		engine.setRenderZone();
		engine.setTarget(null,false,null);
		
		return target;
	}
	
}