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
	var tw(get, null) : mt.deepnight.Tweenie; inline function get_tw() return App.me.tweenie;
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
	
	public var bgBuildings : Scroller;
	
	public var sky : h2d.Bitmap;
	
	public var car : Car;
	public var zombies : Zombies;
	
	public var started = false;
	public var firstTime : Float = 0;
	public var startTime : Float = 0;
	public var nowTime : Float = 0;
	public var prevTime : Float = 0;
	public var dTime : Float = 0;
	
	public var curMidi : MidiStruct;
	
	public var partition : Partition;
	
	//public var firstBeat = false;
	public var score : Int = 0;
	public var progress : Float = 0;
	
	public var score1 : Int = 0;
	public var score2 : Int = 0;
	public var score3 : Int = 0;
	public var score4 : Int = 0;
	
	public var streak : Int = 0;
	public var multiplier : Int = 1;
	public var curLevel = 1;
	
	public var progressCounter:h2d.Number;
	public var scoreText : h2d.Text;
	public var scoreCounter:h2d.Number;
	
	public function new()  {
		me = this;
		masterScene = new h2d.Scene();
		
		tip = new Tip(postScene);
		h2d.Drawable.DEFAULT_FILTER = false;
		gameRoot = new h2d.OffscreenScene2D(590*3, 250*3);
		gameRoot.scaleX = 3;
		gameRoot.scaleY = 3;
	}
	
	public inline function bps() return curMidi.bpm / 60;
	public inline function speed() return Scroller.GLB_SPEED;
	
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
		
		d.sndPrepareMusic1();
		d.sndPrepareMusic2();
		d.sndPrepareMusic3();
		d.sndPrepareMusic4();
		
		curMidi = d.music1Desc;
		
		partition.resetForSignature(curMidi.sig );
		
		var bs = [];
		var b = mt.gx.h2d.Proto.bt( 100, 50, "start",
		start, postScene); bs.push(b);
		
		var b = mt.gx.h2d.Proto.bt( 100, 50, "launch",
		function() {
			partition.launchNote();
		}, postScene); bs.push(b);
		b.x += 110;
		
		var b = mt.gx.h2d.Proto.bt( 80, 50, "level 2",
		function() {
			level2();
		}, postScene);
		b.x += 200; bs.push(b);
		
		var b = mt.gx.h2d.Proto.bt( 80, 50, "level 3",
		function() {
			level3();
		}, postScene);
		b.x += 300; bs.push(b);
		
		var b = mt.gx.h2d.Proto.bt( 80, 50, "level 4",
		function() {
			level4();
		}, postScene);
		b.x += 400; bs.push(b);
		
		for ( b in bs ) b.y += 150;
		
		haxe.Timer.delay( start , 800 );
		
		var pc = progressCounter = new h2d.Number(d.eightSmall,gameRoot);
		pc.x = C.W - 50;
		pc.y = 50;
		pc.trailingPercent = true;
		
		scoreText = new h2d.Text( d.eightSmall, gameRoot);
		scoreText.text = "SCORE";
		scoreText.x = 16;
		scoreText.textColor = 0x0;
		scoreText.dropShadow = { dx:1, dy:1, color:0x4A4A4A, alpha:1.0 };
		
		scoreCounter = new h2d.Number( d.eightSmall, gameRoot );
		scoreCounter.x = scoreText.x +scoreText.width + 4;
		scoreCounter.y = scoreText.y = 8;
		scoreCounter.nb = 0;
		ivory( scoreCounter );
		
		
		
		return this;
	}
	
	inline function orange(txt:h2d.Text) {
		txt.textColor = 0xff9358;
		txt.dropShadow = { dx:2, dy:2, color:0xd804a2d, alpha:1.0 };
	}
	
	inline function ivory(txt:h2d.Text) {
		txt.textColor = 0xffe6b0;
		txt.dropShadow = { dx:2, dy:2, color:0xD804a2d, alpha:1.0 };
	}
	
	var m = new Matrix();

	public function update() {
		var engine : h3d.Engine = h3d.Engine.getCurrent();
		
		postScene.checkEvents();
		preScene.checkEvents();
	
		if( ! App.me.paused ) {
			preUpdateGame();
			d.update();
			postUpdateGame();
		}
		engine.render(masterScene);
		engine.restoreOpenfl();
		
		progressCounter.nb = Std.int(progress * 100);
		scoreCounter.nb = score;
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
		
		bgBuildings = new Scroller(146, 8, d.char.getTile("buildingA"), 
		["buildingA",
		"buildingB",
		"buildingC",
		"buildingD",
		"buildingE",
		].map( function(str) return d.char.getTile(str).centerRatio(0.5,1.0) ), gameRoot);
		bgBuildings.speed = 6.0;
		bgBuildings.originY += 120;
		bgBuildings.randomHide = true;
		bgBuildings.init();
		
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
	
	public function bandeNoirIn() {
		
	}
	
	public function end() {
		stopZombies();
		
		partition.enablePulse = false;
		
		car.car.a.playAndLoop("carStop");
		
		var endScreen = new h2d.Sprite( gameRoot );
		var b = new h2d.Bitmap( h2d.Tile.fromColor( 0xcd000000 ).centerRatio(0.5, 0.5), endScreen );
		b.x = C.W * 0.5;
		b.y = 150;
		b.setSize( C.W, 10 );
		tw.create(b, "y", 		85, 400);
		tw.create(b, "height", 	110, 300);
		
		var localRoot = new h2d.Sprite( endScreen );
		var t = new h2d.Text( d.eightMedium,localRoot );
		t.text = "LEVEL " + curLevel + " COMPLETE";
		t.x = C.W * 0.5 - t.textWidth * 0.5;
		t.y = C.H * 0.2;
		t.letterSpacing = -1;
		t.textColor = 0xff9358;
		t.dropShadow = { dx:2, dy:2, color:0xD804a2d, alpha:1.0 };
		
		localRoot.x -= C.W;
		tw.create(localRoot, "x", 0, TBurnOut,300);
		
		var localRoot2 = new h2d.Sprite( endScreen );
		var n = new h2d.Number(d.eightMediumPlus,localRoot2 );
		n.x = C.W * 0.25;
		n.y = C.H * 0.40 - n.textHeight * 0.5;
		n.letterSpacing = -1;
		n.textColor = 0xffe6b0;
		n.dropShadow = { dx:2, dy:2, color:0xD804a2d, alpha:1.0 };
		
		var t = new h2d.Text( d.eightMediumPlus,localRoot2 );
		t.text = "POINTS";
		t.x = n.x + C.W * 0.25;
		t.y = C.H * 0.40 - t.textHeight * 0.5;
		t.letterSpacing = -1;
		t.textColor = 0xffe6b0;
		t.dropShadow = { dx:2, dy:2, color:0xD804a2d, alpha:1.0 };
		
		localRoot2.x -= C.W;
		haxe.Timer.delay(function() tw.create(localRoot2, "x", 0, TBurnOut,300),100);
		
		n.nb = 0;
		tw.create(n, "nb", score, 1200);
		haxe.Timer.delay( function() {
			var tt = tw.create( localRoot, "x", C.W * 1.5, TBurnOut, 300 );
			haxe.Timer.delay(function(){
				var ttt = tw.create( localRoot2, "x", C.W * 1.5, TBurnOut, 300 );
				ttt.onEnd = function() {
					var tttt = tw.create(b, "scaleY", 0, TBurnIn, 200);
					tttt.onEnd = function(){
						endScreen.dispose();
						nextLevel();
					};
				}
			},100);
		},1200);
	}
	
	public function nextLevel() {
		switch( curLevel) {
			case 1: level2();
			case 2: level3();
			case 3: level4();
			case 4: endGame();
		}
	}
	
	public function stopZombies() {
		started = false;
		zombies.clear();
		partition.enablePulse = false;
	}
	
	public function endGame() {
		var endGameScreen = new h2d.Sprite( gameRoot );
		var b = new h2d.Bitmap( h2d.Tile.fromColor( 0xcd000000 ), endGameScreen );
		b.setSize(C.W, 0);
		b.y = 50;
		b.setSize(C.W, 200);
		var tt = tw.create( b, "y", 40, 200 );
		
		var t = new h2d.Text( d.eightVeryBig );
		t.text = "GAME OVER";
		t.x = C.W * 0.5 - t.textWidth * 0.5;
		t.y = 150;
		
		t.visible = false;
		tt.onEnd = function() {
			t.visible = true;
		}
	}
	
	public function onStart() {
		d.stopAllMusic();
		started = true;
		nowTime = 0;
		startTime = hxd.Timer.oldTime;
		car.reset();
		progress = 0;
		score = 0;
	}
	
	public function afterStart() {
		var startScreen = new h2d.Sprite( gameRoot );
		var b = new h2d.Bitmap( h2d.Tile.fromColor( 0xcd000000 ).centerRatio(0.5, 0.5), startScreen );
		b.x = C.W * 0.5;
		b.y = 150;
		b.setSize( C.W, 10 );
		tw.create(b, "y", 		85, 400);
		tw.create(b, "height", 	110, 300);
		
		var localRoot = new h2d.Sprite( startScreen );
		var t = new h2d.Text( d.eightMedium,localRoot );
		t.text = "LEVEL " + curLevel;
		t.x = C.W * 0.5 - t.textWidth * 0.5;
		t.y = C.H * 0.2;
		t.letterSpacing = -1;
		t.textColor = 0xff9358;
		t.dropShadow = { dx:2, dy:2, color:0xD804a2d, alpha:1.0 };
		
		localRoot.x -= C.W;
		tw.create(localRoot, "x", 0, TBurnOut,300);
		
		var localRoot2 = new h2d.Sprite( startScreen );
		var t = new h2d.Text( d.eightMediumPlus,localRoot2 );
		t.text = switch(curLevel) {
			default:"ERROR";
			case 1: "LUSTY CARESS";
			case 2: "PLANET ERROR";
			case 3: "C3POPOCALYSPE";
			case 4: "BOB ZOMBI";
		};
		t.x = C.W * 0.5 - t.textWidth * 0.5;
		t.y = C.H * 0.40 - t.textHeight * 0.5;
		t.letterSpacing = -1;
		t.textColor = 0xffe6b0;
		t.dropShadow = { dx:2, dy:2, color:0xD804a2d, alpha:1.0 };
		
		localRoot2.x -= C.W;
		haxe.Timer.delay(function() tw.create(localRoot2, "x", 0, TBurnOut,300),100);
		haxe.Timer.delay( function() {
			var tt = tw.create( localRoot, "x", C.W * 1.5, TBurnOut, 300 );
			haxe.Timer.delay(function(){
				var ttt = tw.create( localRoot2, "x", C.W * 1.5, TBurnOut, 300 );
				ttt.onEnd = function() {
					var tttt = tw.create(b, "scaleY", 0, TBurnIn, 200);
				}
			},100);
		},1500);
	}
	
	public function start() {
		
		level2();
		return;
		
		onStart();
		
		d.sndPlayMusic1();
		zombies.setLevel(1);
		
		curMidi = d.music1Desc;
		partition.resetForSignature(curMidi.sig );
		
		haxe.Timer.delay( function() {
			partition.enablePulse = true;
			car.car.a.playAndLoop( "carPlay" );
		},1500);
		score = 0;
		
		afterStart();
	}
	
	public function level2() {
		onStart();
		
		d.sndPlayMusic2();
		zombies.setLevel(2);
		
		curMidi = d.music2Desc;
		partition.resetForSignature(curMidi.sig );
		
		haxe.Timer.delay( function() {
			partition.enablePulse = true;
			car.car.a.playAndLoop( "carPlay" );
		},1500);
		curLevel++;
		
		afterStart();
	}
	
	public function level3() {
		onStart();
		
		d.sndPlayMusic3();
		zombies.setLevel(3);
		
		curMidi = d.music3Desc;
		partition.resetForSignature( curMidi.sig );
		
		haxe.Timer.delay( function() {
			partition.enablePulse = true;
			car.car.a.playAndLoop( "carPlay" );
		},1500);
		curLevel++;
		afterStart();
	}
	
	public function level4() {
		onStart();
		
		d.sndPlayMusic4();
		zombies.setLevel(4);
		
		curMidi = d.music4Desc;
		partition.resetForSignature( curMidi.sig );
		
		haxe.Timer.delay( function() {
			partition.enablePulse = true;
			car.car.a.playAndLoop( "carPlay" );
		},1500);
		curLevel++;
		afterStart();
	}
	
	public function onPause(onOff) {
		car.onPause(onOff);
	}
	
	public var isBeat 	: Bool;
	public var isNote 	: Bool;
	public var isQuarter : Bool;
	
	function updateTempo() {
		isNote = isQuarter = isBeat = false;
		prevTime = nowTime;//in sec
		nowTime = (hxd.Timer.oldTime - startTime); //in sec
		//trace( prevTime +" -> " + nowTime ); 
		
		var prevBeat = prevTime * bps() + C.LookAhead;
		var nowBeat = nowTime * bps() + C.LookAhead;
		
		var pb = Std.int( prevBeat );
		var nb = Std.int( nowBeat );
		//trace("b " + pb + " -> " + nb);
		
		var prevQuarter = prevBeat * curMidi.sig;
		var nowQuarter = nowBeat * curMidi.sig;
		
		var pq = Std.int( prevQuarter );
		var nq = Std.int( nowQuarter );
		//trace("q " + pq + " -> " + nq);
		
		//tick per beat
		var prevTick = prevBeat * curMidi.midi.division;  // in midi frames
		var lastTick = nowBeat * curMidi.midi.division;  // in midi frames
		
		var s = Std.int(prevTick);
		var e = Std.int(lastTick) + 1;
		
		var n = null;
		function seekNote(ti, i, m : TE ) {
			if ( m.message.status == cast com.newgonzo.midi.messages.MessageStatus.NOTE_ON )
				n = m;
			
			if ( m.time != 0 && Std.is( m.message, com.newgonzo.midi.file.messages.EndTrackMessage) ) {
				var mm : com.newgonzo.midi.file.messages.EndTrackMessage = cast m.message;
				if ( mm.type == cast com.newgonzo.midi.file.messages.MetaEventMessageType.END_OF_TRACK) {
					haxe.Timer.delay( end, 6000 );
				}
			}
		}
		
		d.getMessageRange(curMidi.midi,s, e, seekNote);
		
		if( n != null){
			//time should play ? 
			var o_tb =  n.time / curMidi.midi.division;
			var o_ts = (o_tb-C.LookAhead) / bps();
			//trace(prevTime+" " + o_ts + " " + nowTime );
		}
			
		if ( pb != nb ) {
			if ( n != null) {
				onNote();
				isNote = true;
			}
			else{ 
				onBeat();
			}
			isBeat = true;
			progress = lastTick / curMidi.durTick;
		}
		else if ( pq != nq ) {
			if ( n != null) {
				onNote();
				isNote = true;
			}
			else{
				onQuarter();
			}
			isQuarter = true;
		}
		
		
	}
	
	function onQuarter() {
		partition.launchQuarter();
	}
	
	function onBeat() {
		partition.launchStrong();
	}
	
	function onNote() {
		partition.launchNote();
	}
	
	var leftIsDown = 0;
	var rightIsDown = 0;
	
	var updateZombies = true;
	
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
		bgBuildings.update(dTime);
		car.update( dTime );
		
		if( updateZombies )
			zombies.update( dTime );
		
		/*
		if ( mt.flash.Key.isToggled(hxd.Key.C)) {
			zombies.clear();
		}
		
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
		
		if ( mt.flash.Key.isToggled(hxd.Key.G)) {
			var z = zombies.spawnZombiePack();
			for( zz in z ) {
				zz.cs(Nope);
				zz.x += 100;
			}
		}
		*/
		/*
		if ( mt.flash.Key.isToggled(hxd.Key.U)) {
			car.hit();
		}
		
		if ( mt.flash.Key.isToggled(hxd.Key.I)) {
			car.heal();
		}
		
		if ( mt.flash.Key.isToggled(hxd.Key.L)) {
			car.shootLeft();
		}
		
		if ( mt.flash.Key.isToggled(hxd.Key.M)) {
			car.shootRight();
		}
		
		if ( mt.flash.Key.isToggled(hxd.Key.LEFT)) {
			car.tryShootLeft();
		}
		
		if ( mt.flash.Key.isToggled(hxd.Key.RIGHT)) {
			car.tryShootRight();
		}
		*/
		
		if ( mt.flash.Key.isToggled(hxd.Key.V)) {
			end();
		}
		
		if ( mt.flash.Key.isToggled(hxd.Key.E)) {
			endGame();
		}
		
		if (  (	mt.flash.Key.isDown(hxd.Key.LEFT)
		||		mt.flash.Key.isDown(hxd.Key.Q)
		||		mt.flash.Key.isDown(hxd.Key.A))) {
			leftIsDown++;
		}
		else leftIsDown = 0;
		
		if (  	mt.flash.Key.isDown(hxd.Key.RIGHT)
		||		mt.flash.Key.isDown(hxd.Key.D)) {
			rightIsDown++;
		}
		else rightIsDown = 0;
		
		if ( leftIsDown == 1 )
			car.tryShootLeft();
			
		if ( rightIsDown == 1 )
			car.tryShootRight();
	}
	
	public function postUpdateGame() {
		partition.update();
	}
	
	public function loose() {
		zombies.setLevel(0);
	}
	
	public function onMiss() {
		d.sfxKick00.play();
	}
	
	public function onSuccess() {
		
	}
	
	public function scoreZombi() {
		score += 5 * multiplier;
	}
	
	public function scorePerfect() 
	{
		score += 5 * multiplier;
	}
	
	public function scoreGood() 
	{
		score += 3 * multiplier;
	}
	
}