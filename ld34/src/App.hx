import mt.deepnight.slb.BLib;
import mt.deepnight.HParticle;
import h2d.Tile;
import h3d.Matrix;


class App extends flash.display.Sprite {
	public var engine : h3d.Engine;
	public var g : G;
	public var d : D;
	public var tweenie : mt.deepnight.Tweenie;
	public var fxMan : mt.fx.Manager;
	public static var me : App;
	
	function new() {
		super();
		
		fxMan = new mt.fx.Manager();
		me = this;
		engine = new h3d.Engine();
		engine.onReady = init;
		engine.backgroundColor = 0xFF000000;
		engine.init();
	}
	
	function init() {
		d = new D();
		g = new G();
		g.init();
		tweenie = new mt.deepnight.Tweenie();
		tweenie.fps = C.FPS;
		hxd.System.setLoop(update);
	}
	
	function update() {
		mt.flash.Key.update();
		hxd.Timer.update();
		var tm = hxd.Timer.tmod;
		var ttm = hxd.Timer.deltaT * C.FPS;
		//ttm /= 2.0;
		g.update();
		tweenie.update(ttm);
		fxMan.update();
		Part.updateAll(tm);
	}
	
	static function main() {
		new App();
	}
	
}

