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
	public var tip : Tip;
	public static var me : App;
	
	function new() {
		super();
		
		fxMan = new mt.fx.Manager();
		me = this;
		engine = new h3d.Engine();
		engine.onReady = init;
		engine.backgroundColor = 0xFFFFFFFF;
		engine.init();
	}
	
	function init() {
		d = new D();
		g = new G();
		g.init();
		tweenie = new mt.deepnight.Tweenie();
		hxd.System.setLoop(update);
	}
	
	function update() {
		mt.flash.Key.update();
		hxd.Timer.update();
		var tm = hxd.Timer.tmod;
		g.update(tm);
		tweenie.update(tm);
		for( i in 0...Math.round( hxd.Timer.tmod )){
			fxMan.update();
			HParticle.updateAll();
		}
		Part.updateAll(hxd.Timer.tmod);
	}
	
	static function main() {
		new App();
	}
	
}

