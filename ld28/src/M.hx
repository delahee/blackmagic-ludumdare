import flash.display.StageQuality;
import flash.events.Event;
import flash.Lib;
import mt.deepnight.*;
import mt.fx.*;
import volute.*;


@:publicFields
class M {
	
	var timer : Time;
	var tweenie : Tweenie;
	var level :Level;
	var data:Data;
	var ui:Ui;
	
	public static var me : M = null;
	
	
	function stage() {
		return Lib.current.stage;
	}
	
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
		stage().quality = StageQuality.LOW;
	}
	
	public function update(_) {
		timer.update();
		
		for ( i in 0...timer.dfr)
			frameUpdate();
	}
	
	public function frameUpdate() {
		tweenie.update();
		level.update();
		ui.update();
		mt.deepnight.SpriteLibBitmap.updateAll(1.0);
	}
	
	public static function main() {
		Key.init();
		new M();
	}
}