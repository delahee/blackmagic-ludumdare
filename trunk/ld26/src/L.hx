
class L extends starling.display.Sprite
{
	public var asters : Array<Aster>;
	
	public function new() {
		super();
		asters = [];
		touchable = true;
	}
	
	public function addAster( a ) {
		asters.push(a);
		addChild(a.img);
		return a;
	}
	
	public function update() {
		for ( a in asters )
			a.update();
	}
}