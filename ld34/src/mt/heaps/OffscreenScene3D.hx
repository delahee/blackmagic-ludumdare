package mt.heaps;

class OffscreenScene3D extends h3d.scene.Scene {
	var wantedWith : Int;
	var wantedHeight : Int;
	var targetTile:h2d.Tile;
	public var deferScene = true;
	
	public var targetDisplay : h2d.Bitmap;
	public var s2d : h2d.Scene;
	public var targetRatioW = 1.0;
	public var targetRatioH = 1.0;
	
	public function new(w,h) {
		super();
		wantedWith = w;
		wantedHeight = h;
		
		var engine = h3d.Engine.getCurrent();
		var tw = hxd.Math.nextPow2(wantedWith);
		var th = hxd.Math.nextPow2(wantedHeight);

		targetRatioW = wantedWith / tw;
		targetRatioH = wantedWith / th;
	}
	
	function rescale2d(s:h3d.scene.Object) {
		for ( p in extraPasses) {
			var sc : h2d.Scene = Std.instance( p , h2d.Scene);
			if ( sc != null )
				sc.setFixedSize( wantedWith, wantedHeight);
		}
	}
	
	public function checkEvents(){
		s2d.checkEvents();
		for ( p in extraPasses) {
			var sc : h2d.Scene = Std.instance( p , h2d.Scene);
			sc.checkEvents();
		}
	}
	
	public override function render(engine:h3d.Engine) {
		if ( s2d == null ) {
			s2d = new h2d.Scene();
			if ( !deferScene )
				addPass(s2d);
		}
		
		if ( deferScene ) {
			targetTile = renderOffscreen(targetTile);
			if ( targetDisplay == null ) {
				var tex = targetTile.getTexture();
				targetTile.getTexture().realloc = function() {
					if ( targetDisplay != null ){
						targetDisplay.remove();
						targetDisplay = null;
						targetTile.getTexture().dispose();
						targetTile = null;
					}
				}
				targetDisplay = new h2d.Bitmap(targetTile, s2d);
			}
			
			
			s2d.render( engine );
		}
		else {
			for ( p in extraPasses) {
				var sc : h2d.Scene = Std.instance( p , h2d.Scene);
				@:privateAccess sc.fixedSize = false;
				@:privateAccess sc.posChanged = true;
			}
			super.render(engine);
		}
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
		
		autoResize = false;
		camera.screenRatio = wantedWith/wantedHeight;
		camera.update();
		
		traverse( rescale2d );
		
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