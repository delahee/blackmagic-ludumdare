import h3d.Matrix;
import h2d.Tile;
using T;

class G {
	public static var me : G;
	var c(get, null) : CenterScreen; 	function get_c() return CenterScreen.me;
	public var scenes : Map<Dir,h2d.Scene> = new Map();
	public var masterScene : h2d.Scene;
	public var preScene : h2d.Scene = new h2d.Scene();
	public var postScene : h2d.Scene = new h2d.Scene();
	
	public var cadrans : Map<Dir,Elem>;
	public var screens:Array<S>;
	public var colGeneration:Array<Int> = [0, 0, 0];
	public var stopped = false;
	
	var d(get, null) : D; function get_d() return App.me.d;
	var tip : Tip;
	public function new()  {
		me = this;
		masterScene = new h2d.Scene();
		cadrans = new Map();
		cadrans[Top] = Dark;
		cadrans[Bottom] = Light;
		
		cadrans[Left] = Fire;
		cadrans[Right] = Water;
		
		tip = new Tip(postScene);
	}
	
	public function init() {
		masterScene.addPass( preScene );
		var bg = d.decor.h_get("bgDecor", preScene);
		
		for ( i in Dir.createAll() ) {
			var s = null;	
			scenes.set( i, s = new h2d.Scene() );
			masterScene.addPass( s );
		}
		
		screens = [];
		//
		scenes[Top].height = C.BAND_H;
		screens.push(new TopScreen(scenes[Top]));
		
		//
		scenes[Bottom].y = C.H - C.BAND_H;
		scenes[Bottom].height = C.BAND_H;
		screens.push(new BottomScreen(scenes[Bottom]));
		//
		scenes[Left].width = C.BAND_H;
		screens.push(new LeftScreen(scenes[Left]));
		
		//
		scenes[Right].x = C.W -  C.BAND_H;
		scenes[Right].width = C.BAND_H;
		screens.push(new RightScreen(scenes[Right]));
		
		//
		scenes[Center].x = C.BAND_H;
		scenes[Center].y = C.BAND_H;
		scenes[Center].width = C.W - C.BAND_H * 2;
		scenes[Center].height = C.H - C.BAND_H * 2;
		screens.push(new CenterScreen(scenes[Center]));
		//
		masterScene.addPass( postScene );	
		
		for ( k in scenes.keys() ) {
			var v = scenes[k];
			switch(k) {
				default:
					var i = new h2d.Interactive(v.width, v.height);
					i.propagateEvents = true;
					i.blockEvents = false;
					i.cursor = hxd.System.Cursor.Default;
					i.x = v.x;
					i.y = v.y;
					i.onOver = function(_) {
						trace("over " + k);
					}
					
					i.onOut = function(_) {
						trace("over " + k);
					}
				case Center:
			}
			
		}
		
		#if !debug
		launchIntroScreen();
		#else
		c.nextWave();
		#end
		return this;
	}
	
	var m = new Matrix();

	public function update(tmod) {
		var engine : h3d.Engine = h3d.Engine.getCurrent();
		
		engine.render(masterScene);
		engine.restoreOpenfl();
		
		postScene.checkEvents();
		for( i in 0...screens.length )
			screens[screens.length - 1 - i].scene.checkEvents();
		preScene.checkEvents();
		
		#if godMode
		tmod = 1.0;
		#end
		
		#if doubleSpeed
		tmod *= 4.0;
		#end
		
		if ( 	mt.flash.Key.isDown( mt.flash.Key.F ) ) {
			tmod *= 6.0;
		}
		
		if ( stopped ) 
			tmod = 0.0;
		
		for ( s in screens ) 
			s.update( tmod );
		
		if ( 	mt.flash.Key.isToggled( mt.flash.Key.P )
		||		mt.flash.Key.isToggled( mt.flash.Key.SPACE )) {
			stopped = !stopped;
			c.pause.visible  = stopped;
		}
		
		#if debug
		if ( mt.flash.Key.isToggled( mt.flash.Key.E )) {
			launchLostScreen();
		}
		if ( mt.flash.Key.isToggled( mt.flash.Key.V )) {
			launchVictoryScreen();
		}
		if ( mt.flash.Key.isToggled( mt.flash.Key.I )) {
			launchIntroScreen();
		}
		#end
		
		d.update();
	}
	
	public function makeCredits(sp){
		var credits = new h2d.Text(d.wendySmall,sp);
		credits.text = "Audio : Elmobo && Art : Gyhyom && Programming : Blackmagic";
		credits.x = C.W * 0.5 - credits.textWidth * 0.5;
		credits.y = C.H- credits.textHeight - 10;
		credits.textColor = 0xFFff8330;
		credits.dropShadow = { dx:2, dy:2, color:0xFF000000, alpha:1.0 };
	}
	
	public function launchIntroScreen() {
		var sp = new h2d.Sprite( postScene);
		
		var b = d.decor.h_get("title",sp);
		b.x = C.W * 0.5 - b.width * 0.5;
		b.y = C.H * 0.37;
		
		stopped = true;
		c.cleanup();
		
		makeCredits(sp);
		
		var b = d.char.h_get("startTxt",sp);
		b.x = C.W * 0.5 - b.width * 0.5;
		b.y = C.H * 0.60;
		
		var i = new h2d.Interactive( C.W, C.H, sp);
		i.onClick = function(_) {
			restart();
			sp.detach();
		}
		
		d.sndStopBattle();
		d.sndStopBoss();
		d.sndStopGameover();
		d.sndPlayIntro();
	}
	
	public function launchLostScreen() {
		var sp = new h2d.Sprite( postScene);
		
		var b = d.char.h_get("loseTxt",sp);
		b.x = C.W * 0.5 - b.width * 0.5;
		b.y = C.H * 0.2;
		
		stopped = true;
		c.cleanup();
		
		var bt = new h2d.Bitmap(Tile.fromColor(0xFF000000,200,40), sp);
		bt.x = C.W * 0.5 - bt.width * 0.5;
		bt.y = C.H * 0.5 - bt.height * 0.5;
		
		var t = new h2d.Text(d.wendySmall, bt);
		t.text = "PLAY AGAIN";
		t.x = bt.width * 0.5 -t.textWidth * 0.5;
		t.y = bt.height * 0.5 -t.textHeight * 0.5;
		t.textColor = 0xFFFFFFFF;
		
		makeCredits(sp);
		var playMusic = true;
		var i = new h2d.Interactive( C.W, C.H, sp);
		i.onClick = function(_) {
			restart();
			sp.detach();
			playMusic = false;
		}
		
		d.sndStopBattle();
		d.sndStopBoss();
		D.music.jingle_lost_OK().playLoop(1);
		haxe.Timer.delay( function() if(playMusic) d.sndPlayGameover(), 3500);
	}
	
	public function launchVictoryScreen() {
		D.music.jingle_win_OK().play();
		var sp = new h2d.Sprite( postScene);
		stopped = true;
		
		var b = d.char.h_get("winTxt",sp);
		b.x = C.W * 0.5 - b.width * 0.5;
		b.y = C.H * 0.2;
		
		c.cleanupNmy();
		
		for ( c in CenterScreen.me.char)
			if ( c != null )
				c.sp.a.playAndLoop( c.win() );
		
		var bt = new h2d.Bitmap(Tile.fromColor(0xFF000000,200,40), sp);
		bt.x = C.W * 0.5 - bt.width * 0.5;
		bt.y = C.H * 0.5 - bt.height * 0.5;
		
		makeCredits(sp);
		
		var t = new h2d.Text(d.wendySmall, bt);
		t.text = "PLAY AGAIN";
		t.x = bt.width * 0.5 -t.textWidth * 0.5;
		t.y = bt.height * 0.5 -t.textHeight * 0.5;
		t.textColor = 0xFFFFFFFF;
		
		var playMusic = true;
		var i = new h2d.Interactive( C.W, C.H, sp);
		i.onClick = function(_) {
			playMusic = false;
			restart();
			sp.detach();
		}
		
		d.sndStopBattle();
		d.sndStopBoss();
		
		D.music.jingle_win_OK().playLoop(1);
		haxe.Timer.delay( function() if(playMusic) d.sndPlayGameover(), 4500);
	}
	
	function restart() {
		d.sndStopIntro();
		d.sndStopGameover();
		d.sndStopBoss();
		D.sfx.START().play();
		c.cleanup();
		stopped = false;
		c.wave = 0;
		c.nextWave();
	}
}