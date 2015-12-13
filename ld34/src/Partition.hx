import h2d.SpriteBatch;

using mt.gx.Ex;
@:enum abstract ENote(Int){
	var Left = 0;
	var Right = 1;
	//var Both = 2;
}


class NoteSprite extends mt.deepnight.slb.HSpriteBE{
	
	public var t :Float;
	public var tween : mt.deepnight.Tweenie.Tween;
	public function new(sb:h2d.SpriteBatch,l,g) {
		super(sb,l,g);
	}
}

class Partition {

	var d(get, null) : D; function get_d() return App.me.d;
	var g(get, null) : G; function get_g() return App.me.g;
	
	public var grid : h2d.SpriteBatch;
	//public var notes : Array<h2d.SpriteBatch.BatchElement>;
	
	var baseline = 200;
	var fretW = 120;
	var fretPositions : Array<Float>=[];
	
	public function new(p) {
		baseline = C.H - 37;
		resetForSignature(4, p);
		
		//grid.scaleX = -1;
		//grix.x -= 
	}
	
	public function resetForSignature( sig : Int , p) {
		if (grid != null) { grid.dispose(); grid = null; }
			
		grid = new h2d.SpriteBatch( d.char.getTile("pixel").centerRatio(), p );
		
		var e = grid.alloc(d.char.getTile("bgUi").centerRatio(0,0));
		e.y = baseline;
		e.width = C.W;
		
		var fretTile = d.char.getTile("fret").centerRatio(0.5,0);
		var quarter = d.char.getTile("quarter").centerRatio(0.5,0);
		var startX = (C.W - 150);
		for ( i in 0...C.LookAhead ) {
			fretPositions[i] = startX - i * fretW;
			
			if ( i < 1) {
				var e = grid.alloc(fretTile);
				e.x = fretPositions[i];
				e.y = baseline;
			}
			
			if( i <= 0 )
			for ( j in 0...sig-1 ) {
				var e = grid.alloc(quarter);	
				e.x = startX - i * fretW - (j+1) * fretW/sig;
				e.y = baseline;
			}
		}
		
		var e = grid.alloc(quarter);	
		e.x = startX + fretW/sig;
		e.y = baseline;
	}
	
	public function launchQuarter()	{
		var sp = grid.alloc( d.char.getTile("noteHelper").centerRatio(0.5,0) );
		sp.x = fretPositions.last();
		sp.y = baseline + 16;
		
		var t = App.me.tweenie.create( sp, "x", fretPositions[0] + fretW, TLinear, C.LookAhead / g.bps() * 1000 );
		t.onUpdate = function() sp.x = Math.round( sp.x );
		
		t.onEnd = sp.remove;
	}
	
	public function launchStrong()	{
		var sp = grid.alloc( d.char.getTile("noteHelper").centerRatio(0.5,0) );
		sp.scale(2);
		sp.rotation = Math.PI * 0.25;
		sp.x = fretPositions.last();
		sp.y = baseline + 16;
		sp.alpha = 1.2;
		
		var t = App.me.tweenie.create( sp, "x", fretPositions[0] + fretW, TLinear, C.LookAhead / g.bps() * 1000 );
		t.onUpdate = function() sp.x = Math.round( sp.x );
		
		t.onEnd = sp.remove;
	}
	
	public var noteList : List<NoteSprite> = new List();
	
	public function launchNote() {
		//var sp = grid.alloc( d.char.getTile("hit").centerRatio(0,0) );
		var sp : NoteSprite = new NoteSprite(grid, d.char, "hit");
		sp.setCenterRatio(0.5, 0);
		sp.x = fretPositions.last();
		sp.y = baseline;
		
		var tw = App.me.tweenie.create( sp, "x", fretPositions[0] + fretW, TLinear, C.LookAhead / g.bps() * 1000 );
		tw.onUpdateT = function(t) {
			sp.x = Math.round( sp.x );
			sp.t = t;
			if ( sp.x > fretPositions[0] + fretW * 0.5 ){
				noteList.remove(sp);
			}
		};
		
		noteList.pushFront(sp);
		tw.onEnd = function() {
			sp.remove();
		}
		sp.tween = tw;
	}
	
	public function isValidable(sp:NoteSprite){
		return sp.t >= 2.0 / C.LookAhead;
	}
	
	public function tryValidate(sp:NoteSprite) {
		var la = C.LookAhead;
		var extraLow 	= 4.25 	/ la;
		var low 		= 4.5 	/ la;
		var mid 		= 5.0 	/ la;
		var high 		= 5.25 	/ la;
		var t = sp.t;
		var col = 0;
		
		noteList.remove(sp);
		
		var low = fretPositions[1] + fretW * 0.5;
		var high = fretPositions[0] + fretW * 0.5;
		if ( sp.x >= low && sp.x <= high) {
			
			return true;
		}
		else {
			sp.a.playAndLoop("hitMiss");
			//col = 0xff0000;
			return false;
		}
		
	}
}