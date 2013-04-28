package ;

import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.ui.Keyboard;

import starling.display.Image;
import starling.events.TouchEvent;
import starling.events.Touch;
import starling.events.TouchPhase;
import starling.text.TextField;

import volute.fx.FXManager;
import volute.MathEx;

import flash.Lib;
import mt.Ticker;
import mt.deepnight.Key;
import starling.core.Starling;

import starling.events.Event;

import  volute.t.Vec2;

import Data;
import Type;

using volute.Lib;


class M extends starling.display.Sprite {
	
	public static var me : M = null;
	public static var timer : Ticker = new Ticker(flash.Lib.current.stage.frameRate );
	public static var core : Starling;
	public static var data : Data;
	public static var view : View;
	public static var fxMan : FXManager;
	
	public var transition : Image;
	public var scursor = 0;
	public var screens : Array<Screen>;
	
	public var fps : TextField;
	
	
	
	static function main() {
		var stage : flash.display.Stage = flash.Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		
		//Starling.multitouchEnabled = true;
		//core = new starling.core.Starling(M,stage, null, null, "auto", "baseline");
		core = new starling.core.Starling(M, stage );
		core.start();
	}
	
	public function new() {
		super();
		me = this;
		mt.deepnight.Key.init();
		view = new View();
		data = new Data();
		fxMan = FXManager.self;
		
		screens = [ new ScreenTitle(),  new ScreenLevel()
		/*, new ScreenTestPerso(), /*,new ScreenTestLevel()*/, new ScreenTestAster(),
		/*, new ScreenTestPerso()*/
		//new ScreenLevel(),
		//new ScreenTitle(), 
		];
		//setScreen(screens.length - 1);
		setScreen(1);
		
		addEventListener( starling.events.Event.ADDED_TO_STAGE, init);
		
		fps = getTf("FPS");
		fps.y = 40;
		
		addChild(fps);
		touchable = true;
		
		var ac = volute.t.Vec2.angle( new Vec2(0, 1), new Vec2(1, 0));
		var ac = volute.t.Vec2.angle( new Vec2(-1, 0), new Vec2(1, 0));
		var a=1;
		
		addChild(view);
	}
	
	function init() {
		addEventListener(Event.ENTER_FRAME, update);
	}
	
	var spin = 0;
	function update(e){
		timer.update();
		
		#if debug
		if ( Key.isDown( Keyboard.SHIFT ) && Key.isToggled( Keyboard.SPACE) ) 	setScreen( scursor + 1 );
		else#end {
			volute.Lib.assert(null != screens[scursor], "Screen is null narf");
			volute.Lib.assert(screens[scursor].isStarted,"it is likely you missed a Screen super.foo() call");
			screens[scursor].update();
		}
		
		Starling.juggler.advanceTime( timer.dt );
		pix.Element.updateAnims();
		
		if(++spin%10==0)
			fps.text = Std.string(MathEx.trunk( 1.0 / timer.dt, 1));
			
		data.update();
		fxMan.update();
	}
	
	public function setScreen(n:Int){
		n = n % screens.length;
		var i = 0;
		for ( s in screens) {
			if (i == n)	{
				if ( !s.isStarted ) {
					s.init();
					view.addChild(s);
				}
			}
			else	{
				if ( s.isStarted ) s.kill();
				s.detach();
			}
			
			i++;
		}
		scursor = n;
	}
	
	static public function getTf(txt="",x=0.0,y=0.0,sz=20,col:Int = 0xFFFFFF )
	{
		volute.Lib.assert(txt != null);
		var tf = new starling.text.TextField(600, 100, txt,"semibold",false );
		tf.text = txt;
		tf.x = x;
		tf.y = y;
		tf.hAlign = starling.utils.HAlign.LEFT;
		tf.vAlign = starling.utils.VAlign.TOP;
		tf.fontSize = sz;
		tf.color = col;
		
		return tf;
	}
	
	public function makeBlackStrip() {
		
	}
	
	public function unmakeBlackStrip() {
		
	}
}