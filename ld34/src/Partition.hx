import h2d.SpriteBatch;

class Note extends h2d.SpriteBatch.BatchElement{
	
}

class Partition {

	var d(get, null) : D; function get_d() return App.me.d;
	public var grid : h2d.SpriteBatch;
	public var notes : Array<Note>;
	
	public function new(p) {
		grid = new h2d.SpriteBatch( d.char.getTile("pixel").centerRatio(),p );
		
		var baseline = 200;
		var fretW = 120;
		var startX = (C.W - 50);
		for ( i in 0...6 ) {
			var e = grid.alloc();
			e.x = startX - i * fretW;
			e.y = baseline;
			e.setColor( 0xff0000 );
			e.setSize(2, 12);
			
			for ( j in 0...3 ) {
				var e = grid.alloc();	
				e.x = startX - i * fretW - (j+1) * fretW/4;
				e.y = baseline;
				e.setColor( 0xff007f);
				e.setSize(1, 8);
			}
		}
		
		
	}
	
	public function launchNote() {
		
	}
	
}