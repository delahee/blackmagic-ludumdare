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
	public var scaledRoot : h2d.Scene = new h2d.Scene();
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
	
	//public var progressCounter:h2d.Number;
	public var scoreText : h2d.Text;
	public var scoreCounter:h2d.Number;
	
	public var uiVisible = true;
	
	public function new()  {
		me = this;
		masterScene = new h2d.Scene();
		
		tip = new Tip(postScene);
		h2d.Drawable.DEFAULT_FILTER = false;
		gameRoot = new h2d.OffscreenScene2D(590*3, 250*3);
		gameRoot.scaleX = 3;
		gameRoot.scaleY = 3;
		
		scaledRoot.scaleX = scaledRoot.scaleY = 3;
	}
	
	public inline function bps() return curMidi.bpm / 60;
	public inline function speed() return Scroller.GLB_SPEED;
	
	public function init() {
		masterScene.addPass( preScene, true );
		masterScene.addPass( gameRoot );
		masterScene.addPass( scaledRoot );
		masterScene.addPass( postScene );	
		//mt.gx.h2d.Proto.rect( 0, 0, 50, 50, 0xffff00, 1.0, gameRoot);
		//mt.gx.h2d.Proto.rect( 0, 100, 50, 50, 0xff0055, 1.0, postScene);
		
		initBg();
		initCar();
		zombies = new Zombies(gameRoot);
		partition = new Partition( gameRoot );
		
		d.sndPrepareMusic1();
		d.sndPrepareMusic2();
		d.sndPrepareMusic3();
		
		d.sndPrepareMusic4();
		d.sndPrepareJingleStart();
		
		curMidi = d.music1Desc;
		
		partition.resetForSignature(curMidi.sig );
		
		var bs = [];
		var b = mt.gx.h2d.Proto.bt( 100, 50, "start",
		function() restart(curLevel), postScene); bs.push(b);
		
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
		
		
		/*
		var pc = progressCounter = new h2d.Number(d.eightSmall,gameRoot);
		pc.x = C.W - 50;
		pc.y = 50;
		pc.trailingPercent = true;
		*/
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
		
		//haxe.Timer.delay( function() restart(curLevel) , 500 );
		
		partition.visible = false;
		car.visible = false;
		uiVisible = false;
		
		haxe.Timer.delay(
			introMenu,100
		);
		
		return this;
	}
	
	function introMenu() {
		var sp = new h2d.Bitmap( d.char.getTile("logo").centerRatio(), scaledRoot );
		sp.x = C.W * 0.5;
		sp.y = C.H * 0.35;
		
		sp.toFront();
		
		var localRoot = new h2d.Sprite( scaledRoot );
		var t = new h2d.Text( d.eightSmall,localRoot );
		t.text = "CLICK TO CONTINUE";
		t.letterSpacing = -1;
		t.x = C.W * 0.5 - t.textWidth * 0.5;
		t.y = C.H * 0.6;
		t.textColor = 0xff9358;
		ivory(t);
		var ty = t.y;
		t.y = C.H * 1.5;
		tw.create( t, "y", ty, TEaseOut, 1000);
		
		var m = D.music.MUSIC_INTRO();
		m.playLoop();
		var launch = new h2d.Interactive( mt.Metrics.w(), mt.Metrics.h(), postScene);
		function doStart(e) {
			m.stop();
			sp.dispose();
			launch.dispose();
			localRoot.dispose();
			
			partition.visible = true;
			car.visible = true;
			uiVisible = true;
			
			level1();
		}
		launch.onClick = doStart;
	}
	
	public inline function orange(txt:h2d.Text) {
		txt.textColor = 0xff9358;
		txt.dropShadow = { dx:2, dy:2, color:0xd804a2d, alpha:1.0 };
	}
	
	public inline function ivory(txt:h2d.Text) {
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
		
		//progressCounter.nb = Std.int(progress * 100);
		scoreCounter.nb = score;
		scoreText.visible = scoreCounter.visible = uiVisible;
		//progressCounter.visible = uiVisible;
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
		d.stopAllMusic();
		D.sfx.JINGLE_END().play();
		
		partition.enablePulse = false;
		zombies.speed = 0;
		
		for ( i in 0...6)
			haxe.Timer.delay( function() {
				car.shootLeft();
				car.shootRight();
			},i * 100);
			
		tw.create(car, "bx", C.W * 1.5, 550);
		
		haxe.Timer.delay( function() {updateZombies = false; zombies.clear();}, 1500 );
		
		function afterExplode() {
			
			stopZombies();
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
			},2400);
		}
		
		haxe.Timer.delay( afterExplode, 1500 );
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
		
		d.sndPlayJingleStart();
		
		car.by = Car.BASE_BY;
		car.bx = - C.W;
		car.car.a.playAndLoop("carStop");
		var tt = tw.create(car, "bx", Car.BASE_BX, 600);
		///tt.onEnd = function(){
			d.stopAllMusic();
			started = true;
			nowTime = 0;
			startTime = hxd.Timer.oldTime;
			car.reset();
			progress = 0;
			score = 0;
			multiplier = 1;
			zombies.speed = 1;
			updateZombies=true;
		//};
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
	
	public function restart(lvl) {
		switch(lvl) {
			case 1:level1();
			case 2:level2();
			case 3:level3();
			case 4:level4();
		}
	}
	
	inline function startBeat() {
		haxe.Timer.delay( function() {
			partition.enablePulse = true;
			car.car.a.playAndLoop( "carPlay" );
		},2400);
	}
	
	public function level1() {
		curLevel = 1;
		onStart();
		
		d.sndPlayMusic1();
		zombies.setLevel(1);
		
		curMidi = d.music1Desc;
		partition.resetForSignature(curMidi.sig );
		
		startBeat();
		afterStart();
	}
	
	public function level2() {
		curLevel=2;
		onStart();
		
		d.sndPlayMusic2();
		zombies.setLevel(2);
		
		curMidi = d.music2Desc;
		partition.resetForSignature(curMidi.sig );
		
		startBeat();
		afterStart();
	}
	
	public function level3() {
		curLevel=3;
		onStart();
		
		d.sndPlayMusic3();
		zombies.setLevel(3);
		
		curMidi = d.music3Desc;
		partition.resetForSignature( curMidi.sig );
		
		startBeat();
		afterStart();
	}
	
	public function level4() {
		curLevel=4;
		onStart();
		
		d.sndPlayMusic4();
		zombies.setLevel(4);
		
		curMidi = d.music4Desc;
		partition.resetForSignature( curMidi.sig );
		
		startBeat();
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
		if ( started && updateZombies) 
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
		
		if ( updateZombies ) {
			zombies.speed = 1;
			#if	debug
			if ( mt.flash.Key.isDown(hxd.Key.SPACE)) {
				zombies.speed = 20;
			}
			#end
			zombies.update( dTime );
		}
		
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
		
		if ( mt.flash.Key.isToggled(hxd.Key.C)) 	car.gunType = GTCanon;
		if ( mt.flash.Key.isToggled(hxd.Key.G)) 	car.gunType = GTGun;
		if ( mt.flash.Key.isToggled(hxd.Key.S)) 	car.gunType = GTShotgun;
		
		if ( mt.flash.Key.isToggled(hxd.Key.M)) {
			streak = 50;
			multiplier = 50;
		}
		
		if ( mt.flash.Key.isToggled(hxd.Key.V)) {
			end();
		}
		
		if ( mt.flash.Key.isToggled(hxd.Key.L)) {
			loose();
		}
		
		if ( mt.flash.Key.isToggled(hxd.Key.E)) {
			endGame();
		}
		
		if (  (	mt.flash.Key.isDown(hxd.Key.LEFT)
		||		mt.flash.Key.isDown(hxd.Key.Q)
		||		mt.flash.Key.isDown(hxd.Key.DOWN)
		||		mt.flash.Key.isDown(hxd.Key.A))) {
			leftIsDown++;
		}
		else leftIsDown = 0;
		
		if (  	mt.flash.Key.isDown(hxd.Key.RIGHT)
		||		mt.flash.Key.isDown(hxd.Key.UP)
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
		if( updateZombies )
			partition.update();
	}
	
	var isLoosing = false;
	public function loose() {
		//zombies.setLevel(0);
		//updateZombies();
		partition.clear();
		d.stopAllMusic();
		
		if ( isLoosing ) return;
		isLoosing = true;
		
		zombies.speed = -2;
		
		var o = tw.create( car,"bx", - C.W, 1200 );
		o.onEnd = function() {
			updateZombies = false;
		}
		d.stopAllMusic();
		haxe.Timer.delay( function() {
			D.sfx.JINGLE_GAMEOVER().play();
		},400);
		
		haxe.Timer.delay( function() {
			var goScreen = new h2d.Sprite(gameRoot);
			
			var b = new h2d.Bitmap( h2d.Tile.fromColor( 0xcd000000 ).centerRatio(0.5, 0.5), goScreen );
			b.x = C.W * 0.5;
			b.y = 150;
			b.setSize( C.W, 10 );
			tw.create(b, "y", 		100, 400);
			tw.create(b, "height", 	130, 300);
			
			var localRoot = new h2d.Sprite( goScreen );
			var t = new h2d.Text( d.eightMedium,localRoot );
			t.text = "GAMEOVER";
			t.x = C.W * 0.5 - t.textWidth * 0.5;
			t.y = C.H * 0.2;
			t.letterSpacing = -1;
			t.textColor = 0xff9358;
			t.dropShadow = { dx:2, dy:2, color:0xD804a2d, alpha:1.0 };
			
			localRoot.x -= C.W;
			tw.create(localRoot, "x", 0, TBurnOut, 300);
			
			var localRoot2 = new h2d.Sprite( goScreen );
			
			var n = new h2d.Text(d.eightSmall,localRoot2 );
			n.y = C.H * 0.40 - n.textHeight * 0.5;
			n.text = "SCORE "+score;
			n.letterSpacing = -1;
			n.textColor = 0xffe6b0;
			n.dropShadow = { dx:2, dy:2, color:0xD804a2d, alpha:1.0 };
			n.x = C.W * 0.5 - n.textWidth*0.5;
			
			var n = new h2d.Text(d.eightSmall,localRoot2 );
			n.y = C.H * 0.5 - n.textHeight * 0.5;
			n.text = "CLICK TO RESTART";
			n.letterSpacing = -1;
			n.textColor = 0xffe6b0;
			n.dropShadow = { dx:2, dy:2, color:0xD804a2d, alpha:1.0 };
			n.x = C.W * 0.5 - n.textWidth*0.5;
			
			var n = new h2d.Text(d.eightSmall,localRoot2 );
			n.x = C.W * 0.25;
			n.y = C.H * 0.55 - n.textHeight * 0.5;
			n.text = "F1 / F2 / F3 / F4 to jump to level";
			n.letterSpacing = -1;
			n.textColor = 0xffe6b0;
			n.dropShadow = { dx:2, dy:2, color:0xD804a2d, alpha:1.0 };
			n.x = C.W * 0.5 - n.textWidth*0.5;
			
			var goMask = new h2d.Interactive( mt.Metrics.w(), mt.Metrics.h(), postScene);
			
			function f() {
				goScreen.dispose();
				goMask.dispose();
				isLoosing = false;
			}
			
			function onPress(f) {
				
				var tt = tw.create( localRoot, "x", C.W * 1.5, TBurnOut, 300 );
				haxe.Timer.delay(function(){
					var ttt = tw.create( localRoot2, "x", C.W * 1.5, TBurnOut, 300 );
					ttt.onEnd = function() {
						var tttt = tw.create(b, "scaleY", 0, TBurnIn, 200);
						tttt.onEnd = function(){
							f();
						};
					}
				},100);
			}
				
			goMask.onClick = function(e) {
				onPress( function() {
					f();
					restart(curLevel);
				});
			};
			
			goMask.onSync = function() {
				
				if ( mt.flash.Key.isToggled(hxd.Key.F1)) onPress( function() { f(); level1();  } );
				if ( mt.flash.Key.isToggled(hxd.Key.F2)) onPress( function(){ f(); level2();  });
				if ( mt.flash.Key.isToggled(hxd.Key.F3)) onPress( function(){ f(); level3();  });
				if ( mt.flash.Key.isToggled(hxd.Key.F4)) onPress( function(){ f(); level4();  });
			}
		},1300);
	}
	
	public function onMiss() {
		//d.sfxKick00.play();
		partition.triggerMiss(C.W - 30, partition.baseline);
		streak = 0;
		multiplier = 1;
	}
	
	public function onSuccess() {
		
	}
	
	public function scoreZombi(zt:Zombies.ZType) {
		var base = 5;
		switch(zt) {
			default:
			case Girl:base++;
			case Armor:base+=3;
			case Boss:base+=5;
		}
		score += base * multiplier;
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