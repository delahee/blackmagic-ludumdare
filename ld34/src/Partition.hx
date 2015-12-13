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
	public var ok : Bool = false;
	public var missed : Bool = false;
	
	public function new(sb:h2d.SpriteBatch,l,g) {
		super(sb,l,g);
	}
}

class Partition {

	var d(get, null) : D; inline function get_d() return App.me.d;
	var g(get, null) : G; inline function get_g() return App.me.g;
	var tw(get, null) : mt.deepnight.Tweenie; inline function get_tw() return App.me.tweenie;
	
	public var grid : h2d.SpriteBatch;
	public var fx : h2d.SpriteBatch;
	//public var notes : Array<h2d.SpriteBatch.BatchElement>;
	
	var baseline = 200;
	var fretW = 120;
	var fretPositions : Array<Float> = [];
	var curSig = 0;
	
	var parent : h2d.Sprite;
	
	var flameTile : h2d.Tile;
	
	public function new(parent) {
		baseline = C.H - 37;
		this.parent = parent;
		resetForSignature(4);
		initTexts();
		flameTile = d.char.getTile("fxFlame").centerRatio(0.5, 1.0);
	}
	
	public function resetForSignature( sig : Int ) {
		if (grid != null) { grid.dispose(); grid = null; }
		if (fx != null) { fx.dispose(); fx = null; }
			
		grid = new h2d.SpriteBatch( d.char.getTile("pixel").centerRatio(), parent );
		fx = new h2d.SpriteBatch( d.char.getTile("pixel").centerRatio(), parent ); fx.blendMode = Add;
		var e = grid.alloc(d.char.getTile("bgUi").centerRatio(0,0));
		e.y = baseline;
		e.width = C.W;
		
		var fretTile = d.char.getTile("fret").centerRatio(0.5,0);
		var quarter = d.char.getTile("quarter").centerRatio(0.5,0);
		var startX = (C.W - 150);
		for ( i in 0...C.LookAhead) {
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
		
		curSig = sig;
		
		if( miss!=null){
			miss.toFront();
			good.toFront();
			perfect.toFront();
			for ( g in guides) {
				g.toFront();
			}
		}
	}
	
	function getT(sp) {
		return App.me.tweenie.create( sp, "x", fretPositions[0]+fretW, TLinear, (C.LookAhead+1) / g.bps() * 1000 );
	}
	
	function getX() {
		return fretPositions.last() - (fretW * curSig);
	}
	
	public function launchQuarter()	{
		var sp = grid.alloc( d.char.getTile("noteHelper").centerRatio(0.5,0) );
		sp.x = getX();
		sp.y = baseline + 16;
		
		var t = getT(sp);
		t.onUpdate = function() sp.x = Math.round( sp.x );
		
		t.onEnd = sp.remove;
	}
	
	public function launchStrong()	{
		var sp = grid.alloc( d.char.getTile("noteHelper").centerRatio(0.5,0) );
		sp.scale(2);
		sp.rotation = Math.PI * 0.25;
		sp.x = getX();
		sp.y = baseline + 16;
		sp.alpha = 1.2;
		
		var t =  getT(sp);
		t.onUpdate = function() sp.x = Math.round( sp.x );
		
		t.onEnd = sp.remove;
	}
	
	public var noteList : List<NoteSprite> = new List();
	
	public function launchNote() {
		//var sp = grid.alloc( d.char.getTile("hit").centerRatio(0,0) );
		var sp : NoteSprite = new NoteSprite(grid, d.char, "hit");
		sp.setCenterRatio(0.5, 0);
		sp.x = getX();
		sp.y = baseline;
		
		var tw =  getT(sp);
		tw.onUpdateT = function(t) {
			sp.x = Math.round( sp.x );
			sp.t = t;
			if ( sp.x > highVal() && !sp.missed && !sp.ok){
				noteList.remove(sp);
				sp.a.play("hitMiss");
				triggerMiss(sp.x + 30, sp.y);
				sp.missed = true;
				g.streak = 0;
				g.mutiplier = 0;
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
	
	var good : h2d.Text;
	var perfect : h2d.Text;
	var miss : h2d.Text;
	
	function initTexts() {
		good = new h2d.Text( d.eightSmall, parent );
		good.text = "GOOD";
		good.textColor = 0xffe6b0;
		good.dropShadow = { dx:1,dy:1,color:0xD58F00, alpha:1.0 };
		
		perfect = new h2d.Text( d.eightSmall, parent );
		perfect.text = "PERFECT";
		perfect.textColor = 0xB0F1FF;
		perfect.dropShadow = { dx:1,dy:1,color:0x00AFD5, alpha:1.0 };
		
		miss = new h2d.Text( d.eightSmall, parent );
		miss.text = "MISS";
		miss.textColor = 0xB00000;
		miss.dropShadow = { dx:1, dy:1, color:0x550000, alpha:1.0 };
		
		perfect.alpha = good.alpha = miss.alpha = 0;
		
		//good.x = 100;
		//good.y = 100;
		
		//initGuides();
		good.toFront();
		perfect.toFront();
		miss.toFront();
	}
	
	function center(txt:h2d.Text,x,y) {
		txt.x = x;
		txt.y = y ;
		txt.x -= txt.textWidth * 0.5;
		txt.y -= txt.textHeight * 0.5;
	}
	
	function triggerMiss(x, y) {
		var txt = miss;
		txt.alpha = 1.0;
		center(miss, x, y);
		var t = tw.create( miss, "alpha", 0.3, TBurnIn, 375);
		t.onEnd = function() miss.alpha = 0.0;
		var t = tw.create( miss, "x", txt.x + 40, 375);
	}
	
	function triggerPerfect(x, y) {
		var txt = perfect;
		txt.alpha = 1.0;
		center(perfect, x, y);
		var t = tw.create( perfect, "y", y - 20,TBurnIn, 375);
		t.onUpdateT = function(t) txt.alpha = (1.0 - t);
	}
	
	function triggerGood(x, y) {
		var txt = good;
		txt.alpha = 1.0;
		center(good, x, y);
		var t = tw.create( good, "y", y - 20,TBurnIn, 375);
		t.onUpdateT = function(t) txt.alpha = (1.0 - t);
	}
	
	var guides = [];
	function initGuides() {
		guides.push( h2d.Graphics.fromBounds( h2d.col.Bounds.fromValues(fretPositions[0] - 1, baseline, 2, 10), grid));
		guides.push( h2d.Graphics.fromBounds( h2d.col.Bounds.fromValues(fretPositions[0]+fretW - 1, baseline, 2, 10), grid));
		guides.push( h2d.Graphics.fromBounds( h2d.col.Bounds.fromValues(fretPositions[1] - 1, baseline, 2, 10), grid));	
		
		guides.push( h2d.Graphics.fromBounds( h2d.col.Bounds.fromValues(fretPositions[1] + fretW * 0.25 - 1, baseline, 2, 10), grid,0x00ff00));
		guides.push( h2d.Graphics.fromBounds( h2d.col.Bounds.fromValues(fretPositions[0] - fretW * 0.25 - 1, baseline, 2, 10), grid,0x00ff00));
		guides.push( h2d.Graphics.fromBounds( h2d.col.Bounds.fromValues(fretPositions[0] + fretW * 0.25 - 1, baseline, 2, 10), grid,0x00ffff));
	}
	
	inline function lowVal() return fretPositions[1] + fretW * 0.25;
	inline function highVal() return fretPositions[0] + fretW * 0.25;
	
	public function tryValidate(sp:NoteSprite) {
		var la = C.LookAhead;
		var t = sp.t;
		var col = 0;
		
		var low = lowVal();
		var mid = fretPositions[0] - fretW * 0.25;
		var high = fretPositions[0] + fretW * 0.25;
		
		var ofsX = 0;
		var ofsY = -10;
		if ( sp.x >= low && sp.x <= high) {
			var f = fx.alloc( flameTile );
			f.x = sp.x;
			f.y = sp.y + 20;
			var t = tw.create( f, "alpha", 0.3, TBurnIn, 150);
			t.onUpdateT = function(t) {
				f.scaleX = 1.0 - t;
				f.scaleY = 1.0 + 2 * t;
			}
			tw.forceTerminateTween(  sp.tween );
			
			t.onEnd = function() {
				f.remove();
				sp.dispose();
			}
			if ( sp.x >= mid && sp.x < high) 
				triggerPerfect(sp.x+ofsX,sp.y+ofsY);
			else 
				triggerGood(sp.x + ofsX, sp.y + ofsY);
			onOk();
			
			sp.ok = true;
			noteList.remove(sp);
			return true;
		}
		else {
			return false;
		}
		
	}
	
	public function onOk() {
		g.streak++;
		g.mutiplier = Math.round(Math.log( g.streak ) / Math.log( 2 ));
	}
}