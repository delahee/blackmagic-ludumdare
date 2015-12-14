import h2d.SpriteBatch;

import Car;
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
	
	public var baseline = 0;
	var fretW = 120;
	var fretPositions : Array<Float> = [];
	var curSig = 0;
	
	var parent : h2d.Sprite;
	
	var flameTile : h2d.Tile;
	var pulseSprite : mt.deepnight.slb.HSpriteBE;
	
	var starPower : mt.deepnight.slb.HSpriteBE;
	var bgStarPower : mt.deepnight.slb.HSpriteBE;
	public var enablePulse = false;
	
	var curMultiplier : h2d.Number;
	public var curWeapon : h2d.Text;
	
	public function new(parent) {
		baseline = C.H - 42;
		this.parent = parent;
		
		flameTile = d.char.getTile("fxFlame").centerRatio(0.5, 1.0);
		
		curMultiplier = new h2d.Number(d.eightVerySmall,parent);
		curMultiplier.y = C.H - 20;
		curMultiplier.x = C.W - 30;
		curMultiplier.headingMul = true;
		curMultiplier.nb = 1;
		g.ivory(curMultiplier);
		
		var txt = curWeapon = new h2d.Number(d.eightVerySmall,curMultiplier);
		txt.text = "GUN";
		txt.y = 10;
		g.orange(txt);
		
		resetForSignature(4);
		initTexts();
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
		
		if ( pulseSprite != null ) pulseSprite.remove();
		pulseSprite = new mt.deepnight.slb.HSpriteBE( fx,d.char,"fxPulse");
		pulseSprite.setCenterRatio( 0.5, 0);
		pulseSprite.x = fretPositions[0];
		pulseSprite.y = baseline;
		pulseSprite.alpha = 0;
		
		noteList = new List();
		
		bgStarPower = new mt.deepnight.slb.HSpriteBE( grid, d.char, "bgStarPower");
		bgStarPower.setCenterRatio(0, 0);
		starPower = new mt.deepnight.slb.HSpriteBE( grid,d.char,"starPower");
		starPower.setCenterRatio(0, 0);
		
		starPower.setPos(0, C.H - 8);
		starPower.width = 0;
		bgStarPower.setPos(0, C.H - 8);
		bgStarPower.width = C.W;
		
		curMultiplier.toFront();
		curWeapon.toFront();
	}
	
	inline function quarter() return fretW / curSig;
	
	function getT(sp) {
		if( curSig == 4 )
			return App.me.tweenie.create( sp, "x", fretPositions[0] + fretW //+ quarter()
			, TLinear, (C.LookAhead + 1) / g.bps() * 1000 );
		else 
			return App.me.tweenie.create( sp, "x", fretPositions[0] + fretW - quarter(), TLinear, (C.LookAhead + 1) / g.bps() * 1000 );
	}
	
	function getX() {
		//return fretPositions.last() - (fretW * curSig);
		if( curSig == 4 )
			return fretPositions.last() - (fretW * curSig) //+ quarter()
			;
		else 
			return fretPositions.last() - (fretW * curSig) - quarter();
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
		var sp = grid.alloc( d.char.getTile("strong").centerRatio(0.5,0) );
		sp.x = getX();
		sp.y = baseline + 15;
		sp.alpha = 0.8;
		
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
			if ( sp.destroyed ) return;
			sp.x = Math.round( sp.x );
			sp.t = t;
			if ( sp.x > highVal() && !sp.missed && !sp.ok) {
				g.onMiss();
				noteList.remove(sp);
				sp.a.play("hitMiss");				
				sp.missed = true;
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
		
		initGuides();
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
	
	public function triggerMiss(x, y) {
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
		//if ( false ) 
		{
			guides.push( h2d.Graphics.fromBounds( h2d.col.Bounds.fromValues(fretPositions[0] - 1, baseline, 2, 10), 		parent));
			guides.push( h2d.Graphics.fromBounds( h2d.col.Bounds.fromValues(fretPositions[0]+fretW - 1, baseline, 2, 10), 	parent));
			guides.push( h2d.Graphics.fromBounds( h2d.col.Bounds.fromValues(fretPositions[1] - 1, baseline, 2, 10), 		parent));	
			
			guides.push( h2d.Graphics.fromBounds( h2d.col.Bounds.fromValues(fretPositions[1] + fretW * 0.25 - 1, baseline, 2, 10), parent,0x00ff00));
			guides.push( h2d.Graphics.fromBounds( h2d.col.Bounds.fromValues(fretPositions[0] - fretW * 0.25 - 1, baseline, 2, 10), parent,0x00ff00));
			guides.push( h2d.Graphics.fromBounds( h2d.col.Bounds.fromValues(fretPositions[0] + fretW * 0.25 - 1, baseline, 2, 10), parent, 0x00ffff));
		}
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
		if ( sp.x < low) {
			g.onMiss();
			return false;
		}
		
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
			if ( sp.x >= mid && sp.x < high) {
				g.scorePerfect();
				triggerPerfect(sp.x + ofsX, sp.y + ofsY);
			}
			else {
				g.scoreGood();
				triggerGood(sp.x + ofsX, sp.y + ofsY);
			}
			onOk();
			
			sp.ok = true;
			noteList.remove(sp);
			return true;
		}
		else {
			return false;
		}
		
	}
	
	
	var limit1 = 5;
	var limit2 = 10;
	public function maxMultiplier(){
		var limit = 3;
		switch(g.curLevel) {
			default:
			case 2: limit = limit1;
			case 3: limit = limit2;
			case 4: limit = 15;
		}
		return limit;
	}
	
	public function syncGun() {
		if ( g.multiplier >= limit2 ) {
			Car.me.gunType = GunType.GTCanon;
		}
		else if ( g.multiplier >= limit1 ) {
			Car.me.gunType = GunType.GTShotgun;
		}
		else 
			Car.me.gunType = GunType.GTGun;
	}
	
	public function onOk() {
		g.streak++;
		//trace(g.streak);
		var m = 1 + Math.log( g.streak ) / Math.log( 1.75 );
		trace(m);
		g.multiplier = Std.int(m);
		if ( g.multiplier > maxMultiplier())
			g.multiplier = maxMultiplier();
	}
	
	public function update() {
		if (  g.isBeat && enablePulse)
			pulseSprite.alpha = 0.7;
		else 
			pulseSprite.alpha = hxd.Math.lerp( pulseSprite.alpha , 0 , 0.1 );
			
		starPower.width = C.W * hxd.Math.clamp( (g.multiplier - 1) / (maxMultiplier() - 1), 0, 1 );
		curMultiplier.nb = g.multiplier;
		
		syncGun();
	}
}