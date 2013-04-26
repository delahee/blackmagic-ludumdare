
class Screen extends starling.display.Sprite{
	public var isStarted = false;
	public function new() 
	{
		super();
		visible = false;
	}

	public function getName() :String return Std.string(Type.getClass(this))
	
	/** Dont forget to call me */
	public function init()
	{
		isStarted = true;
		visible = true;
	}
	
	
	/** returns true whether you shoould continue the kill */
	public function kill()
	{
		if ( !isStarted ) return false;
		
		isStarted = false;
		visible = false;
		return true;
	}
	
	public function update()
	{
		if (!isStarted) return;
	}
}