package fx;
import starling.display.MovieClip;

/**
 * ...
 * @author de
 */
class Blink
{
	var fr = 20;
	var mc:MovieClip;
	public function new(mc) 
	{
		super();
	}
	
	public function update()
	{
		fr -= M.timer.dt;
		mc.alpha = Math.sin( M.timer.curT / 4.0 );
		return fr > 0;
	}
	
}