import flash.display.Sprite;
import flash.display.StageQuality;
import flash.events.Event;
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
	public function new() {
		playIntro = true;
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
		stage().quality = StageQuality.LOW;
		
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
		intro.x = 240;
		intro.y = 80;
		intro.scaleX = intro.scaleY = 2.0;
		
		if(playIntro){
			stage().addChild(intro);
			intro.play();
			ui.visible = false;
			canPlay = false;
		}
		else {
			ui.visible = true;
			canPlay = true;
		}
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