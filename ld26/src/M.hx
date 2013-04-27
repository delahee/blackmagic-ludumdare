package ;

import flash.display.StageAlign;
import flash.display.StageScaleMode;
import starling.events.TouchEvent;
import starling.events.Touch;
import starling.events.TouchPhase;
import starling.text.TextField;
import volute.MathEx;

import flash.Lib;
import mt.Ticker;
import starling.core.Starling;

import starling.events.Event;

import Data;
using volute.Lib;


class M extends starling.display.Sprite {
	
	public static var me = M;
	public static var game : G = null;
	public static var timer : Ticker = new Ticker(flash.Lib.current.stage.frameRate );
	public static var core : Starling;
	public static var data : Data;
	
	public var scursor = 0;
	public var screens : Array<Screen>;
	
	public var fps : TextField;
	
	static function main() {
		var stage : flash.display.Stage = flash.Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		
		Starling.multitouchEnabled = true;
		//core = new starling.core.Starling(M,stage, null, null, "auto", "baseline");
		core = new starling.core.Starling(M, stage );
		core.start();
	}
	
	public function new() {
		super();
		
		data = new Data();
		game = new G();	
		
		screens = [ new ScreenTitle(), new ScreenTestAster(), new ScreenTestPerso(), new ScreenTestLevel() ];
		setScreen(screens.length-1);
		addEventListener( starling.events.Event.ADDED_TO_STAGE, init);
		
		fps = getTextField("FPS");
		fps.y = 40;
		
		addChild(fps);
		
		touchable = true;
		/*
		fps.touchable = true;
		fps.addEventListener( TouchEvent.TOUCH , function mup(e:TouchEvent)
		{
			trace('fpstouched');
			var touch : Touch = e.touches[0];
			if(touch!=null){
				if(touch.phase == TouchPhase.ENDED)
				{
					var loc = touch.getLocation(fps);
					trace("mup on " + loc );
				}
		}});
		*/
	}
	
	function init() {
		addEventListener(Event.ENTER_FRAME, update);
	}
	
	var spin = 0;
	function update(e){
		timer.update();
		if ( mt.deepnight.Key.isToggled(flash.ui.Keyboard.SPACE) ) 	setScreen( scursor + 1 );
		else {
			volute.Lib.assert(null != screens[scursor], "Screen is null narf");
			volute.Lib.assert(screens[scursor].isStarted,"it is likely you missed a Screen super.foo() call");
			screens[scursor].update();
		}
		
		Starling.juggler.advanceTime( timer.dt );
		pix.Element.updateAnims();
		
		if(++spin%10==0)
			fps.text = Std.string(MathEx.trunk( 1.0 / timer.dt,1));
	}
	
	function setScreen(n:Int){
		n = n % screens.length;
		var i = 0;
		for ( s in screens) {
			if (i == n)	{
				if ( !s.isStarted ) {
					s.init();
					addChild(s);
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
	
	static public function getTextField(txt="",x=0.0,y=0.0,sz=20)
	{
		var tf = new starling.text.TextField(600, 100, txt, "arial",false );
		tf.text = txt;
		tf.x = x;
		tf.y = y;
		tf.hAlign = starling.utils.HAlign.LEFT;
		tf.vAlign = starling.utils.VAlign.TOP;
		tf.fontSize = sz;
		tf.color = 0xFF00FF00;
		
		return tf;
	}
}