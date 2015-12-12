import h3d.Matrix;
import h2d.Tile;
using T;

class G {
	public static var me : G;
	public var masterScene : h2d.Scene;
	public var preScene : h2d.Scene = new h2d.Scene();
	public var postScene : h2d.Scene = new h2d.Scene();
	public var gameRoot : h2d.OffscreenScene2D;
	public var stopped = false;
	
	var d(get, null) : D; function get_d() return App.me.d;
	var tip : Tip;
	
	public var sbCity : h2d.SpriteBatch;
	public var sbRocks : h2d.SpriteBatch;
	public var sbRoad : h2d.SpriteBatch;
	
	public var rocks:Array<h2d.Sprite>=[];
	
	public var curSpeed : Float = 1.0;
	public var curPos : Float = 0.0;
	
	public var road : Scroller;
	public var bg : Scroller;
	
	public function new()  {
		me = this;
		masterScene = new h2d.Scene();
		
		tip = new Tip(postScene);
		h2d.Drawable.DEFAULT_FILTER = false;
		gameRoot = new h2d.OffscreenScene2D(590*3, 250*3);
		gameRoot.scaleX = 3;
		gameRoot.scaleY = 3;
	}
	
	public function init() {
		masterScene.addPass( preScene, true );
		masterScene.addPass( gameRoot );
		masterScene.addPass( postScene );	
		mt.gx.h2d.Proto.rect( 0, 0, 50, 50, 0xffff00, 1.0, gameRoot);
		mt.gx.h2d.Proto.rect( 0, 100, 50, 50, 0xff0055, 1.0, postScene);
		
		initBg();
		return this;
	}
	
	var m = new Matrix();

	public function update() {
		var engine : h3d.Engine = h3d.Engine.getCurrent();
		
		engine.render(masterScene);
		engine.restoreOpenfl();
		
		postScene.checkEvents();
		preScene.checkEvents();
	
		preUpdateGame();
		
		d.update();
		
		postUpdateGame();
	}
	
	public function makeCredits(sp){
		var credits = new h2d.Text(d.wendySmall,sp);
		credits.text = "Audio : Elmobo && Art : Gyhyom && Programming : Blackmagic";
		credits.x = mt.Metrics.w() * 0.5 - credits.textWidth * 0.5;
		credits.y = mt.Metrics.h()- credits.textHeight - 10;
		credits.textColor = 0xFFff8330;
		credits.dropShadow = { dx:2, dy:2, color:0xFF000000, alpha:1.0 };
	}
	
	var rockLen = 100;
	
	public function initBg() {
		bg = new Scroller(200, 8, d.char.tile, 
			[	d.char.getTile("bg01"),
				d.char.getTile("bg02"),
				d.char.getTile("bg03") 	],
			gameRoot);
		bg.speed = 0.5;
		bg.init();
		
		road = new Scroller(200, 8, d.char.tile, 
			[	d.char.getTile("road01"),
				d.char.getTile("road02"),
				d.char.getTile("road03") 	],
			gameRoot);
		road.speed = 1;
		road.originY += C.H >> 1;
		road.init();
	}
	
	public function getRock(i) {
		return mt.gx.h2d.Proto.rect(0,0,rockLen,C.H / 2,(i%2==0) ? 0xFF00FF : 0xffff00,0.5,gameRoot);
	}
	
	public function preUpdateGame() {
		curPos += curSpeed;
		road.update();
		bg.update();
	}
	
	public function postUpdateGame() {
		
	}
	
}