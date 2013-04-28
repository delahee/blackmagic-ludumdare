package volute.fx;
import haxe.Timer;

/**
 * ...
 * @author de
 */

class FX
{
	public var duration : Null<Float>;
	var t0 : Float;
	
	public function new(q : String = null, d : Null<Float>)
	{
		duration = d;
		t0 = Timer.stamp();
		FXManager.self.add(q,this);
		
		onKill = function() { };
	}
	
	public function time()return Timer.stamp()

	public function reset()
	{
		t0 = Timer.stamp();
	}
	
	//[0 ... 1]
	public inline function t() : Float
	{
		return (time() - t0) / duration;
	}
	
	//in seconds
	public function date()
	{
		return (time() - t0);
	}
	
	//please only set by terminal user, otherwise override kill
	public dynamic function onKill()
	{
		
	}
	
	public function kill()
	{
		onKill();
		duration = 0;
	}
	
	//return false whence wanna kill
	public function update() :  Bool
	{
		if(duration != null)
		{
			var resp = time() <= t0 + duration;
			if( resp == false )
				kill();
			return resp;
		}
		else
		{
			//never expire
			return true;
		}
	}
}