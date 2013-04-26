package ;

import flash.display.StageAlign;
import flash.display.StageScaleMode;
import starling.text.TextField;
import volute.MathEx;

import flash.Lib;
import mt.Ticker;
import starling.core.Starling;

import starling.events.Event;

using volute.Lib;


class M extends starling.display.Sprite {
	
	public static var me = M;
	public static var game : G = null;
	public static var timer : Ticker = new Ticker(flash.Lib.current.stage.frameRate );
	public static var core : Starling;
	
	public var scursor = 0;
	public var screens : Array<Screen>;
	
	public var fps : TextField;
	
	static function main() {
		var stage : flash.display.Stage = flash.Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		
		
		core = new starling.core.Starling(M,stage);
		core.start();
	}
	
	public function new() {
		super();
		screens = [ new ScreenTitle() ];
		setScreen(screens.length-1);
		addEventListener( starling.events.Event.ADDED_TO_STAGE, init);
		game = new G();	
		
		fps = getTextField("FPS");
		fps.y = 40;
		addChild(fps);
	}
	
	function init() {
		addEventListener(Event.ENTER_FRAME, update);
	}
	
	var spin = 0;
	function update(e){
		timer.update();
		if ( mt.flash.Key.isToggled(flash.ui.Keyboard.SPACE) ) 	setScreen( scursor + 1 );
		else {
			Lib.assert(null != screens[scursor], "Screen is null narf");
			Lib.assert(screens[scursor].isStarted,"it is likely you missed a Screen super.foo() call");
			screens[scursor].update();
		}
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