
class L extends starling.display.Sprite
{
	public var asters : Array<Aster>;
	public var grid: Grid;
	
	public static var me : L;
	
	public function new() {
		super();
		asters = [];
		touchable = true;
		me = this;
		grid = new Grid();
	}
	
	public function addAster( a ) {
		asters.push(a);
		grid.add( a );
		a.grid = grid;
		addChild(a.img);
		return a;
	}
	
	public function kill(){
		
	}
	
	public function update() {
		for ( a in asters )
			a.update();
	}
}