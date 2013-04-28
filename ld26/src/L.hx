
class L extends starling.display.Sprite
{
	public var asters : Array<Aster>;
	public static var me : L;
	
	public function new() {
		super();
		asters = [];
		touchable = true;
		me = this;
	}
	
	public function addAster( a ) {
		asters.push(a);
		addChild(a.img);
		return a;
	}
	
	public function kill()
	{
		
	}
	
	public function update() {
		for ( a in asters )
			a.update();
	}
}