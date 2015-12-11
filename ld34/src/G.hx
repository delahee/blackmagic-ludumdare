import h3d.Matrix;
import h2d.Tile;
using T;

class G {
	public static var me : G;
	public var masterScene : h2d.Scene;
	public var preScene : h2d.Scene = new h2d.Scene();
	public var postScene : h2d.Scene = new h2d.Scene();
	public var stopped = false;
	
	var d(get, null) : D; function get_d() return App.me.d;
	var tip : Tip;
	
	public function new()  {
		me = this;
		masterScene = new h2d.Scene();
		
		tip = new Tip(postScene);
	}
	
	public function init() {
		masterScene.addPass( preScene );

		masterScene.addPass( postScene );	
		
		return this;
	}
	
	var m = new Matrix();

	public function update(tmod) {
		var engine : h3d.Engine = h3d.Engine.getCurrent();
		
		engine.render(masterScene);
		engine.restoreOpenfl();
		
		postScene.checkEvents();
		
		preScene.checkEvents();
	
		d.update();
	}
	
	public function makeCredits(sp){
		var credits = new h2d.Text(d.wendySmall,sp);
		credits.text = "Audio : Elmobo && Art : Gyhyom && Programming : Blackmagic";
		credits.x = mt.Metrics.w() * 0.5 - credits.textWidth * 0.5;
		credits.y = mt.Metrics.h()- credits.textHeight - 10;
		credits.textColor = 0xFFff8330;
		credits.dropShadow = { dx:2, dy:2, color:0xFF000000, alpha:1.0 };
	}
}