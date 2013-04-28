package fx;

/**
 * ...
 * @author de
 */
class Delay extends volute.fx.FX
{
	public var proc : Void->Void;
	public function new(d,f) 
	{
		super(d);
		proc = f;
	}
	
	public override function kill()
	{
		super.kill();
		proc();
	}
	
	
}