package fx;
import starling.display.MovieClip;

/**
 * ...
 * @author de
 */
class Blink extends volute.fx.FX
{
	var mc:MovieClip;
	public function new(mc) {
		super( 0.5);
		this.mc = mc;
	}
	
	public override function update(){
		mc.alpha = Math.abs( Math.sin( M.timer.curT * 20.0) );
		return super.update();
	}
	
	public override function kill() {
		super.kill();
		mc.alpha = 1.0;
	}
	
}