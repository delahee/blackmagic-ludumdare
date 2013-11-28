package ;

import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.Lib;
import Ods;
using volute.com.Ex;
import mt.deepnight.Key;
typedef K = flash.ui.Keyboard;

import flash.media.Sound;
import flash.media.SoundMixer;

class StartDing extends Sound { }
class Step1 extends Sound { }
class Step2 extends Sound { }
//class Gerbe1 extends Sound { }
//class Gerbe2 extends Sound { }
class Head1 extends Sound { }
class Head2 extends Sound { }
class Miss extends Sound { }
class Music extends Sound {}
/**
 * ...
 * @author de
 */


class M implements haxe.Public
{
	static var data : Data = new Data();
	static var bb : flash.display.Sprite = new flash.display.Sprite();
	static var bbLevelRoot : flash.display.Sprite = new flash.display.Sprite();
	static var level : Level;
	static var levels : Array<Level>;
	static var char : Char;
	static var ui : Ui;
	static var tweenie : mt.deepnight.Tweenie;
	static var fxMan : fx.FxMan;
	static var op : List < Void->Void >;
	static var nextLevel : Null<Int>;
	static var stats : volute.com.Stats;
	static var intro : gfx.Intro;
	static var endScreen : gfx.EndScreen;
	static var titleScreen : gfx.TitleScreen;
	
	public static var sndMiss : Miss = new Miss();
	public static var sndHead :Array<Sound> = 
	[
		new Head1(), new Head2()
	];
	
	static inline var GAME_DUR = 111.0;
	static inline var CHANGE_FPS = true;
	static inline var BASE_FPS = 60;
	
	static function main() 
	{
		mt.deepnight.Key.init();
		var stage = Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		
		tweenie = new mt.deepnight.Tweenie();
		fxMan = new fx.FxMan();
		stage.addChild(bb);
		bb.scaleX = 2;
		bb.scaleY = 2;
		
		op = new List();
		
		endScreen = new gfx.EndScreen();
		titleScreen = new gfx.TitleScreen();
		intro = new gfx.Intro();
		intro.y = -800;
		
		if(CHANGE_FPS)
			stage.frameRate = 12;
		
		var startIntro = #if debug false #else true #end;
		var startEnd = false;
		
		if (startEnd)
		{
			terminate();
		}
		else
		if( startIntro )
		{
			bb.addChild( intro);
			Lib.current.addEventListener( flash.events.Event.ENTER_FRAME, preUpdate);
		}
		else 
			startup();
	}
	
	static var prevFrame = -1;
	static function preUpdate(_)
	{
		if ( prevFrame == intro.currentFrame #if debug || Key.isDown(K.S) #end )
		{
			SoundMixer.stopAll();
			intro.stop();
			bb.removeChild( intro);
			
			Lib.current.removeEventListener( flash.events.Event.ENTER_FRAME, preUpdate );
			bb.addChild( titleScreen );
			if(CHANGE_FPS)
				Lib.current.stage.frameRate = BASE_FPS;
			Lib.current.addEventListener( flash.events.Event.ENTER_FRAME, titleUpdate );
			new StartDing().play();
		}
		prevFrame = intro.currentFrame;
	}
	
	
	static var score: flash.text.TextField = null;
	static var souls : flash.text.TextField = null;
	static var received : flash.text.TextField = null;
	static var thanks : flash.text.TextField = null;
	
	static var player : ElementEx = null;
	
	static function terminate()
	{
		SoundMixer.stopAll();
		new StartDing().play();
		
		if(CHANGE_FPS)
			Lib.current.stage.frameRate = BASE_FPS;
		Lib.current.removeEventListener( flash.events.Event.ENTER_FRAME, update );
		
		bb.removeChildren();
		bb.addChild( endScreen );
		
		function bl(tf:flash.text.TextField)
		{
			tf.textColor = 0xffFFff;
			tf.filters = [new flash.filters.GlowFilter(0, 1, 10, 10, 5)];
			return tf;
		}
		
		function ct( tf :flash.text.TextField)
		{
			tf.x = Tools.gw() * 0.5 - tf.textWidth*0.5;
			return tf;
		}
			
		function up(str:String)
			return str.toUpperCase();
			
		score 		= bl(Ui.getTf( up("SCORE : "+ char.score), true ));
		souls 		= bl(Ui.getTf( up("SOULS : "+ char.souls), true ));
		received 	= bl(Ui.getTf( up(""), true ));
		thanks 		= bl(Ui.getTf( up("Thanks for playing :D"), true ));

		var d = 25;
		var b = 50;
		
		received.y = b+=d;
		souls.y = b+=d;
		score.y = b+=d;
		thanks.y = b+=d;
		
		player = new ElementEx();
		
		var s =  char == null ? 0 : char.score;
		var hasWon = false;
		if(hasWon=(s >= 666))
		{
			
			data.mkChar(player, "hero", "stand");
			received.text = "YOU RE NOW THE DEATH !";
		}
		else
		{
			data.mkChar(player, "hero", "dead");
			received.text = "ETERNAL PAIN THAT IS!";
		}
		
		ct(score);	
		ct(souls);
		ct(received);
		ct(thanks);

		player.x = Std.int(Tools.gw() * 0.5);
		player.y = Std.int(215);
		
		if(hasWon)
			player.filters = [ new flash.filters.GlowFilter(0x0, 1, 20, 20)];
		
		endScreen.addChild( score );
		endScreen.addChild( souls );
		endScreen.addChild( player );
		endScreen.addChild( received );
		endScreen.addChild( thanks );
		
		Lib.current.addEventListener( flash.events.Event.ENTER_FRAME, termUpdate);
		
	}
	
	static var exiting = false;
	static function termUpdate(_)
	{
		pix.Element.updateAnims();
		if ( Key.isDown(K.SPACE) || Key.isDown(K.CONTROL))
		{
			exiting = true;
			reset();
			Lib.current.removeEventListener( flash.events.Event.ENTER_FRAME, termUpdate);
			exiting = false;
		}
	}
	
	
	static function titleUpdate(_)
	{
		if ( Key.isDown( K.SPACE ) || Key.isDown(K.CONTROL))
		{
			Lib.current.removeEventListener( flash.events.Event.ENTER_FRAME, titleUpdate );
			titleScreen.stop();
			titleScreen.detach();
			startup();
		}
	}
	
	static function nameGen()
	{
		var seed = 4553;
		
		var p  = [
		"Robert",
		"Bob",
		"Emmy",
		"Kelly",
		"Addison",
		"Pamela",
		"Brenda",
		"Cindy",
		"Erika",
		"Jade",
		"Layla",
		"Megan",
		"Brendon",
		"Billy",
		"Dylan",
		"Bill",
		"Steve",
		];
		
		var s = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
		var r = [];
		for ( ps in 0...s.length)
			r.push(s.charAt(ps)+".");
		
		for(i in 0...300)
			trace( p.random() + " " + r.random());
	}
	
	
	static function reset()
	{
		bb.removeChildren();
		bb.addChild(bbLevelRoot);
		M.data.reset();
		if(levels!=null)
		for( l in levels)
		{
			l.kill();
		}
		bbLevelRoot.removeChildren();
		
		char = new Char();
		levels = [];
		levels.push( new Level(0) );
		levels.push( new Level(1) );
		levels.push( new Level(2) );
		levels.push( new Level(3) );
		for(l in levels)
			l.root.visible = false;
		setLevel(1);
		bbLevelRoot.x = 0;
		nextLevel = null;
			
		new Music().play();
		
		Lib.current.addEventListener( flash.events.Event.ENTER_FRAME, update);
		
		score.detach();
		souls.detach();
		player.detach();
		received.detach();
		thanks.detach(); 
		ui = new Ui();
		bb.addChild( ui.root );
		ui.root.toFront();
	}
	
	static function startup()
	{
		if(CHANGE_FPS)
			Lib.current.stage.frameRate = BASE_FPS;
		stats = new volute.com.Stats();
		bbLevelRoot = new flash.display.Sprite();
		reset();
	}
	
	static function setLevel(i:Int)
	{
		bbLevelRoot.removeChildren();
			
		if ( level != null)
			level.leaveLevel();
			
		var tl = null;
		for ( l in levels)
			if (l.idx == i)
				tl = l;
		level = tl;
		bbLevelRoot.addChild( level.root );	
		char.detach();
		level.add( char );
		level.update();
		level.enterLevel();
		level.root.visible = true;
		
	}
	
	public static var slow_every = 10;
	static var slow =  0;
	static var fr  = 0;
	static var enableSlow = false;
	
	static function update(_)
	{
		fr++;
		
		#if debug
		if (enableSlow)
		{
			slow++;
			if ( slow != slow_every )
				return;
			else
				slow = 0;
		}
		#end	
		
		if (level == null )
			return;
			
		#if debug
		if ( Key.isDown(K.E) )
			level.iterEntities(function(e) if ( Std.is(e, Peon) ) (cast e).slice());
		if ( Key.isDown( K.S ) )
		{
			terminate();
			return;
		}
		if ( Key.isDown( K.D ) )
		{
			trace('D');
		}
		if ( Key.isDown( K.T ) )
		{
			enableSlow = true;
		}
		#end
		
		var stage = Lib.current.stage;
		
		level.update();
		ui.update();
		
		tweenie.update();
		fxMan.update();
		
		var bnear = Tools.gw() * 0.5;
		var bfar = Tools.lw()  - Tools.w() * 0.5;
		
		if ( 	char.spr.x >= bnear
		&& 		char.spr.x <= bfar )
		{
			bbLevelRoot.x = Tools.gw() * 0.5 - char.spr.x;
		}
		level.updateBg();
			
		op.iter( function(c) c() );
		op.clear();//i sck
		pix.Element.updateAnims();
		
		#if debug
		if( Key.isDown(K.A) )
		{
			bbLevelRoot.x = 0;
		}
		#end
		
		if ( nextLevel != null)
		{
			setLevel( nextLevel);
			bbLevelRoot.x = 0;
			nextLevel = null;
			M.char.pause = false;
		}
	}
	
}