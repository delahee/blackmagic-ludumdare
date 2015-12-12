import h2d.SpriteBatch;

@:enum abstract ENote(Int){
	var Left = 0;
	var Right = 1;
	var Both = 2;
}

class Partition {

	var d(get, null) : D; function get_d() return App.me.d;
	var g(get, null) : G; function get_g() return App.me.g;
	
	public var grid : h2d.SpriteBatch;
	public var notes : Array<h2d.Sprite>;
	
	var baseline = 200;
	var fretW = 120;
	var fretPositions : Array<Float>=[];
	
	public function new(p) {
		grid = new h2d.SpriteBatch( d.char.getTile("pixel").centerRatio(),p );
		
		var startX = (C.W - 50);
		for ( i in 0...6 ) {
			
			fretPositions[i] = startX - i * fretW;
			
			if( i < 1){
				var e = grid.alloc();
				e.setColor( 0xff0000 );
				e.setSize(2, 12);
				e.x = fretPositions[i];
				e.y = baseline;
			}
			
			if( i <= 0 )
			for ( j in 0...3 ) {
				var e = grid.alloc();	
				
				e.setColor( 0xff007f);
				e.setSize(1, 8);
				
				e.x = startX - i * fretW - (j+1) * fretW/4;
				e.y = baseline;
			}
		}
		
		var e = grid.alloc();	
		e.setColor( 0xff007f );
		e.setSize(1, 8);
		e.x = startX + fretW/4;
		e.y = baseline;
	}
	
	public function launchNote( note : ENote ) {
		var sp = new h2d.Sprite( g.gameRoot );
		sp.x = fretPositions[5];
		sp.y = baseline;
		
		var r = new h2d.Text( d.arial, sp );
		r.text = switch(note) {
			case Left:"<-";
			case Right:"->";
			case Both:"<>";
		}
		r.x -= r.width * 0.5;
		r.y -= r.height * 0.5;
		
		var d = fretPositions[1] - fretPositions[0]; // 1 beat dist
		var t = App.me.tweenie.create( sp, "x", fretPositions[0] + fretW, TLinear, 6 / C.BPS * 1000 );
		
		var once = false;
		t.onUpdateT = function(t) {
			
			var extraLow = 4.25 / 6.0;
			var low = 4.5 / 6.0;
			var mid = 5.0 / 6.0;
			var high = 5.25 / 6.0;
			if ( t >= extraLow ) {
				var acc = (t - extraLow) / ( high - extraLow );
				if ( t <= low ) {
					r.textColor = 0x80FF80;
				}
				else if ( t <= high ) {
					r.textColor = 0x00FF00;
				}
				else if ( t > high ) {
					r.textColor = 0xff0000;
				}
				else {
					r.textColor = 0xffffff;
				}
			}
		}
	}
	
}