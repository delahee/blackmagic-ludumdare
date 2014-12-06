import h3d.Matrix;
import h2d.Tile;
using T;

class G {
	public static var me : G;
	public var scenes : Map<Scenes,h2d.Scene> = new Map();
	public var masterScene : mt.heaps.OffscreenScene3D;
	public var preScene : h2d.Scene = new h2d.Scene();
	public var postScene : h2d.Scene = new h2d.Scene();
	
	public function new()  {
		me = this;
		masterScene = new mt.heaps.OffscreenScene3D(C.W, C.H);
	}
	
	public function init() {
		masterScene.addPass( preScene );
		for ( i in Scenes.createAll() ) {
			var s = null;	
			scenes.set( i, s = new h2d.Scene() );
			masterScene.addPass( s );
		}
		//
		scenes[Top].height = C.BAND_H;
		new TopScreen(scenes[Top]);
		//
		scenes[Bottom].y = C.H - C.BAND_H;
		scenes[Bottom].height = C.BAND_H;
		new BottomScreen(scenes[Bottom]);
		//
		scenes[Left].width = C.BAND_H;
		new LeftScreen(scenes[Left]);
		
		//
		scenes[Right].x = C.W -  C.BAND_H;
		scenes[Right].width = C.BAND_H;
		new RightScreen(scenes[Right]);
		//
		scenes[Center].x = C.BAND_H;
		scenes[Center].y = C.BAND_H;
		scenes[Center].width = C.W - C.BAND_H;
		scenes[Center].height = C.H - C.BAND_H;
		new CenterScreen(scenes[Center]);
		
		masterScene.addPass( postScene );	
		return this;
	}
	
	var m = new Matrix();

	public function update(tmod) {
		var engine : h3d.Engine = h3d.Engine.getCurrent();
		
		engine.setRenderZone();
		engine.render(masterScene);
		engine.setRenderZone();
		engine.restoreOpenfl();
		
		masterScene.targetDisplay.colorMatrix = m;
		
	}
	
}