import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Matrix;
import flash.Lib;
import haxe.Timer;
import mt.deepnight.*;
import mt.deepnight.Tweenie.TType;
import mt.fx.*;
import volute.*;

using volute.Ex;

@:publicFields
class M {
	
	var timer : Time;
	var tweenie : Tweenie;
	var level :Level;
	var data:Data;
	var ui:Ui;
	
	public static var me : M = null;
	
	var canPlay = false;
	
	var intro : gfx.Intro;
	var ending : gfx.Ending;
	function stage() {
		return Lib.current.stage;
	}
	
	var playIntro = #if debug false #else true #end;
	var playEnding = false;
	public function new() {
		me = this;
		data = new Data();
		
		var tiles = data.getTiles();
		timer = new Time();
		tweenie = new Tweenie();
		level = new Level( tiles.layers[0].width, tiles.layers[0].height);
		
		var r = level.getRender();
		stage().addChild( level.getRender() );
		level.postInit();
		
		stage().addChild( ui = new Ui() );
		ui.scaleX = ui.scaleY = 2;
		
		stage().addEventListener( Event.ENTER_FRAME , update );
		
		
		/*
		var f = new Sprite();
		f.graphics.beginFill(0);
		f.graphics.drawRect(0,0,640,640);
		f.graphics.endFill();
		var t = tweenie.create(f, "alpha", 0, TType.TLinear, 0.375);
		//ui.addChild(f);
		*/
		intro = new gfx.Intro();
		ending = new gfx.Ending();
		
		intro.stop();
		
		if ( playEnding) {
			ending.x += 240;
			ending.y += 220;
			ending.scaleX = ending.scaleY = 2.0;
			stage().addChild(ending);
		}
		else if (playIntro) {
			var sp = new Sprite();
			sp.addChild(intro);
			sp.scaleX = sp.scaleY = 2.0;
			sp.x += 240;
			sp.y += 220;
			stage().addChild(sp);
			intro.play();
			ui.visible = false;
			canPlay = false;
		}
		else {
			ui.visible = true;
			canPlay = true;
		}
		
		//bloodAt( hero.el.x, hero.el.y);
		stage().addEventListener( flash.events.MouseEvent.MOUSE_DOWN, level.onMouseDown );
		stage().addEventListener( flash.events.MouseEvent.MOUSE_UP, level.onMouseUp );
	}
	
	public function endGame() {
		canPlay = false;
		ending.x += 240;
		ending.y += 220;
		ending.scaleX = ending.scaleY = 2.0;
		stage().addChild(ending);
		
		var tf = new flash.text.TextField();
			
		var tft = new flash.text.TextFormat('nokiafc22',24,0xF56016);
		tf.setTextFormat( tf.defaultTextFormat = tft ); 
		tf.embedFonts = true;
		
		
		tf.width = 500;
		tf.height = 100;
		tf.y = 400;
		
		tf.filters = [ new flash.filters.GlowFilter(0xc201e, 1, 4 , 4, 20) ];
		tf.text = "$" + Std.string( ui.score);
		tf.width = tf.textWidth + 5;
		tf.x = 240 - tf.width * 0.5;
		stage().addChild( tf ); 
	}
	
	
	public function update(_) {
		timer.update();
		
		for ( i in 0...timer.dfr)
			frameUpdate();
			
		if ( intro.currentFrame >= intro.totalFrames - 1) {
			ui.visible = true;
			canPlay = true;
			intro.alpha *= 0.95;
		}
		else if ( intro.alpha >= 0.99) {
			
		}
		
		if ( intro.alpha <= 0) {
			
			intro.detach();
		}
	}
	
	public function frameUpdate() {
		tweenie.update();
		if( canPlay)
			level.update();
		ui.update();
		mt.deepnight.SpriteLibBitmap.updateAll(1.0);
	}
	
	public static function main() {
		Key.init();
		new M();
	}
}