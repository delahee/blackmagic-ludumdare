import h3d.Matrix;
import h2d.Tile;
import D;
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
	
	public var started = false;
	public var firstTime : Float = 0;
	public var nowTime : Float = 0;
	public var prevTime : Float = 0;
	public var dTime : Float = 0;
	public var curMidi : com.newgonzo.midi.file.MIDIFile;
	public var partition : Partition;
	public var firstBeat = false;
	
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
		
		partition = new Partition( gameRoot );
		
		curMidi = d.midiFile;
		
		var b =mt.gx.h2d.Proto.bt( 100, 50, "start",
		start, postScene);
		
		var b =mt.gx.h2d.Proto.bt( 100, 50, "launch",
		function() {
			partition.launchNote(Left);
		}, postScene);
		b.x += 110;
		
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
			[	d.char.getTile("bgA"),
				d.char.getTile("bgB"),
				d.char.getTile("bgC"),
				d.char.getTile("bgD")],
			gameRoot);
		bg.speed = 0.5;
		bg.init();
		
		road = new Scroller(200, 8, d.char.tile, 
			[	d.char.getTile("roadA"),
				d.char.getTile("roadB"),
				d.char.getTile("roadC") 	,
				d.char.getTile("roadD") 	],
			gameRoot);
		road.speed = 6.0;
		road.originY += C.H >> 1;
		road.init();
	}
	
	public function getRock(i) {
		return mt.gx.h2d.Proto.rect(0,0,rockLen,C.H / 2,(i%2==0) ? 0xFF00FF : 0xffff00,0.5,gameRoot);
	}
	
	public function start() {
		started = true;
		nowTime = hxd.Timer.oldTime;
		firstBeat = true;
	}
	
	public function preUpdateGame() {
		if ( started ) 
			updateTempo();
		else 
			dTime = 1.0 / C.FPS;
			
		curPos += curSpeed * dTime;
			
		road.update(dTime);
		bg.update(dTime);
	}
	
	function updateTempo() {
		prevTime = nowTime;//in sec
		nowTime = hxd.Timer.oldTime; //in sec
		
		var prevBeat = prevTime * C.BPS + C.LookAhead;
		var nowBeat = nowTime * C.BPS + C.LookAhead;
		
		//tick per beat
		var prevTick = prevBeat * curMidi.division;  // in midi frames
		var lastTick = nowBeat * curMidi.division;  // in midi frames
		
		var s = Math.ceil(prevTick);
		var e = Math.floor(lastTick);
		
		//var pBeat = Math.ceil(prevBeat);
		//var nBeat = Math.floor(nowBeat);
		
		//trace( "pre:" + s + " e:" + e);
		//trace( "pre b:" + pBeat + " e b:" + nBeat);
		
		var pb = Math.round( prevBeat );
		var nb = Math.round( nowBeat );
		if ( pb != nb ) {
			//trace( pb + " <> " + nb);
			onBeat();
			firstBeat = false;
		}
		/*
		d.getMessageRange( s,e,
		function(ti:Int,i:Int,e:TE) :Void{
			trace("#" +i+" t:"+e.time+" msg:"+ e.message);
		});
		*/
	}
	
	function onBeat() {
		partition.launchNote(Left);
	}
	
	public function postUpdateGame() {
	}
	
}