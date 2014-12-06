
import mt.deepnight.slb.BLib;
import h2d.Tile;
import h3d.Matrix;

enum Scenes {
	Top;
	Left;
	Right;
	Bottom;
}

class App extends flash.display.Sprite {
	
	var engine : h3d.Engine;
	var scenes : Map<Scenes,h2d.Scene> = new Map();
	var masterScene : mt.heaps.OffscreenScene3D;
	function new() {
		super();
		engine = new h3d.Engine();
		engine.onReady = init;
		engine.backgroundColor = 0xFFCCCCCC;
		engine.init();
	}
	
	function init() {
		hxd.System.setLoop(update);
		hxd.Key.initialize();
		
		masterScene = new mt.heaps.OffscreenScene3D(C.W,C.H);
		for ( i in Scenes.createAll() ) {
			var s = null;	
			scenes.set( i, s = new h2d.Scene() );
			new h2d.Bitmap( Tile.fromColor(0xFF00FFFF, 100, 100), s );
			masterScene.addPass( s );
		}
		
		scenes[Bottom].y = C.H - C.BAND_H;
	}
	
	function update() {
		engine.render(masterScene);
		engine.restoreOpenfl();
		
		var m = new Matrix();
		m.colorHue( 0.5 );
		masterScene.targetDisplay.colorMatrix = m;
	}
	
	static function main() {
		new App();
	}
	
}
