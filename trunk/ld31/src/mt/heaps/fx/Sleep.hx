﻿package mt.heaps.fx;

class Sleep extends mt.fx.Fx 
{
	var f: mt.fx.Fx;
	var count:Int;
	var onWakeUp:Void->Void;
	
	public function new(?f,?onWakeUp,count=10) {
		this.f = f;
		this.onWakeUp = onWakeUp;
		this.count = count;
		Fx.DEFAULT_MANAGER.remove(f);
		super();
	}
	
	override function update() {
		super.update();
		if( count-- <= 0 ) {
			if( f!= null ){
				Fx.DEFAULT_MANAGER.add(f);
				f.update();
			}
			if( onWakeUp != null ) onWakeUp();
			kill();
		}
	}
	
	public function hide(mc:h2d.sprite,play=false) {
		mc.visible = false;
		if ( play ) mc.stop();
		onWakeUp = function() {
			mc.visible = true;
			if ( play ) mc.play();
		}
	}
}
