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
	public var bgRocks : Scroller;
	public var bgSand : Scroller;
	public var sky : h2d.Bitmap;
	
	public var car : Car;
	public var zombies : Zombies;
	
	public var started = false;
	public var firstTime : Float = 0;
	public var startTime : Float = 0;
	public var nowTime : Float = 0;
	public var prevTime : Float = 0;
	public var dTime : Float = 0;
	
	public var curMidi : com.newgonzo.midi.file.MIDIFile;
	public var curMusicSignature = 0;
	public var curBpm = 0;
	
	public var partition : Partition;
	
	//public var firstBeat = false;
	
	public function new()  {
		me = this;
		masterScene = new h2d.Scene();
		
		tip = new Tip(postScene);
		h2d.Drawable.DEFAULT_FILTER = false;
		gameRoot = new h2d.OffscreenScene2D(590*3, 250*3);
		gameRoot.scaleX = 3;
		gameRoot.scaleY = 3;
	}
	
	public inline function bps() return curBpm / 60;
	
	public function init() {
		masterScene.addPass( preScene, true );
		masterScene.addPass( gameRoot );
		masterScene.addPass( postScene );	
		mt.gx.h2d.Proto.rect( 0, 0, 50, 50, 0xffff00, 1.0, gameRoot);
		mt.gx.h2d.Proto.rect( 0, 100, 50, 50, 0xff0055, 1.0, postScene);
		
		initBg();
		initCar();
		zombies = new Zombies(gameRoot);
		partition = new Partition( gameRoot );
		
		curMidi = d.midiFile2;
		curMusicSignature = 4;
		curBpm = 120;
		
		partition.resetForSignature(curMusicSignature,gameRoot );
		
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
	
		if( ! App.me.paused ) {
			preUpdateGame();
			d.update();
			postUpdateGame();
		}
	}
	
	public function makeCredits(sp){
		var credits = new h2d.Text(d.wendySmall,sp);
		credits.text = "Audio : Elmobo && Art : Gyhyom && Programming : Blackmagic";
		credits.x = mt.Metrics.w() * 0.5 - credits.textWidth * 0.5;
		credits.y = mt.Metrics.h()- credits.textHeight - 10;
		credits.textColor = 0xFFff8330;
		credits.dropShadow = { dx:2, dy:2, color:0xFF000000, alpha:1.0 };
	}
	
	public function initBg() {
		sky = new h2d.Bitmap(d.char.getTile("sky"), gameRoot);
		
		bg = new Scroller(600, 8, d.char.getTile("bg"), [], gameRoot);
		bg.speed = 0.5;
		bg.originY += 40;
		bg.init();
		
		bgRocks = new Scroller(600, 8, d.char.getTile("bgRocks"), [], gameRoot);
		bgRocks.speed = 2.0;
		bgRocks.originY += 65;
		bgRocks.init();
		
		bgSand = new Scroller(600, 8, d.char.getTile("bgSand"), [], gameRoot);
		bgSand.speed = 6.0;
		bgSand.originY += 100;
		bgSand.init();
		
		road = new Scroller(200, 8, d.char.tile, 
			[	d.char.getTile("roadA"),
				d.char.getTile("roadB"),
				d.char.getTile("roadC"),
				d.char.getTile("roadD")],
			gameRoot);
		road.speed = 6.0;
		road.originY += C.H >> 1;
		road.init();
	}
	
	public function initCar() {
		car = new Car( gameRoot );
	}
	
	public function start() {
		started = true;
		startTime = hxd.Timer.oldTime;
		nowTime = 0;
		zombies.setLevel(1);
	}
	
	public function onPause(onOff) {
		car.onPause(onOff);
	}
	
	
	
	function updateTempo() {
		prevTime = nowTime;//in sec
		nowTime = (hxd.Timer.oldTime - startTime); //in sec
		trace( prevTime +" -> " + nowTime ); 
		
		var prevBeat = prevTime * bps() + C.LookAhead;
		var nowBeat = nowTime * bps() + C.LookAhead;
		
		var pb = Std.int( prevBeat );
		var nb = Std.int( nowBeat );
		trace("b " + pb + " -> " + nb);
		
		var prevQuarter = prevBeat * curMusicSignature;
		var nowQuarter = nowBeat * curMusicSignature;
		
		var pq = Std.int( prevQuarter );
		var nq = Std.int( nowQuarter );
		trace("q " + pq + " -> " + nq);
		
		//tick per beat
		var prevTick = prevBeat * curMidi.division;  // in midi frames
		var lastTick = nowBeat * curMidi.division;  // in midi frames
		
		var s = Std.int(prevTick);
		var e = Std.int(lastTick) + 1;
		
		var n = null;
		function seekNote(ti, i, m : TE ) {
			if ( m.message.status == cast com.newgonzo.midi.messages.MessageStatus.NOTE_ON ){
				n = m;
			}
		}
		
		d.getMessageRange(curMidi,s, e, seekNote);
		
		if ( pb != nb ) {
			if ( n != null) {
				trace( n );
				onNote(Left);
			}
			else 
				onBeat();
		}
		else if ( pq != nq ) {
			onQuarter();
		}
		
	}
	
	function onQuarter() {
		partition.launchQuarter();
	}
	
	function onBeat() {
		partition.launchStrong();
	}
	
	function onNote(l) {
		partition.launchNote(l);
	}
	
	public function preUpdateGame() {
		if ( started ) 
			updateTempo();
		else 
			dTime = 1.0 / C.FPS;
			
		curPos += curSpeed * dTime;
			
		road.update(dTime);
		bg.update(dTime);
		bgRocks.update(dTime);
		bgSand.update(dTime);
		car.update( dTime );
		zombies.update( dTime );
		
		if ( mt.flash.Key.isToggled(hxd.Key.Z)) {
			zombies.spawnZombieBase();
		}
		
		if ( mt.flash.Key.isToggled(hxd.Key.E)) {
			for( i in 0...6)
				zombies.spawnZombieBase();
		}
		
		if ( mt.flash.Key.isToggled(hxd.Key.R)) {
			for( i in 0...3)
				zombies.spawnZombieHigh();
		}
		
		if ( mt.flash.Key.isToggled(hxd.Key.T)) {
			for( i in 0...3)
				zombies.spawnZombieLow();
		}
		
		if ( mt.flash.Key.isToggled(hxd.Key.U)) {
			car.hit();
		}
		
		if ( mt.flash.Key.isToggled(hxd.Key.I)) {
			car.heal();
		}
	}
	
	public function postUpdateGame() {
		var n = zombies.countCarZombies();
		
		if ( n > 10 )
			n = 10;
			
		var u = 0.02;
		var handicap = u * n;
		
		if ( Scroller.GLB_SPEED > 1.0 - handicap )
			Scroller.GLB_SPEED -= u;
			
		if ( Scroller.GLB_SPEED < 1.0 - handicap )
			Scroller.GLB_SPEED += u;
	}

	
	public function loose() {
		zombies.setLevel(0);
	}
	
}