
class Scroller {
	var g(get, null) : G; function get_g() return App.me.g;
	var d(get, null) : D; function get_d() return App.me.d;
	
	var sb : h2d.SpriteBatch;
	public var size : Int;
	
	public static var GLB_SPEED = 1.0;
	public var speed = 1.0;
	public var nb : Int;
	public var originY = 0;
	public var tiles : Array<h2d.Tile> = [];
	public var deck : Array<h2d.Tile>=[];
	
	var master : h2d.Tile;
	
	public function new(size,nb,masterTile,tiles,p){
		sb = new h2d.SpriteBatch(masterTile, p);
		this.size = size;
		this.nb = nb;
		this.tiles = tiles;
		master = masterTile;
		init();
	}
	
	function getTile() {
		if ( deck.length == 0 )
			if( tiles.length > 0 )
				deck = tiles.copy();
			else 
				return master;
			
		var r = Std.random(deck.length);
		var e = deck[r];
		deck.remove( e );
		return e;
	}
	
	public function init() {
		sb.removeAllElements();
		for ( i in 0...nb ) {
			var r = sb.alloc( getTile() );
			r.x = i * size;
			r.y = originY;
		}
	}
	
	public function update(dTime:Float) {
		var fr = dTime * C.FPS;
		for ( e in sb.getElements()) {
			e.x -= speed * GLB_SPEED * fr;
			if ( e.x <= -size )
				e.x += size * nb;
		}
	}
}