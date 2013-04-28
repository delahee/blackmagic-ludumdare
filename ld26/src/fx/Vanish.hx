package fx;
import starling.display.DisplayObject;

/**
 * ...
 * @author de
 */
class Vanish extends volute.fx.FX
{
	public var mc : DisplayObject;
	public var sy : Float = 0;
	public function new( mc , d = 0.5) {
		super( d );
		this.mc = mc;
	}
	
	public override function update() {
		var ratio = t();
		mc.alpha = 0.5 + (1.0 - ratio) *0.5;
		mc.y -= sy * ratio;
		return super.update();
	}
	
	public override function kill() {
		super.kill();
		mc.alpha = 0.0;
		mc.removeFromParent( true );
		mc = null;
	}
	
}