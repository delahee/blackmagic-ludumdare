import mt.deepnight.slb.BLib;
import h2d.Tile;
import h3d.Matrix;


class App extends flash.display.Sprite {
	public var engine : h3d.Engine;
	public var g : G;
	public static var me : App;
	
	function new() {
		super();
		me = this;
		engine = new h3d.Engine();
		engine.onReady = init;
		engine.backgroundColor = 0xFFCCCCCC;
		engine.init();
	}
	
	function init() {
		hxd.System.setLoop(update);
		hxd.Key.initialize();
		g = new G();
		g.init();
	}
	
	function update() {
		hxd.Timer.update();
		g.update(hxd.Timer.tmod);
	}
	
	static function main() {
		new App();
	}
	
}

