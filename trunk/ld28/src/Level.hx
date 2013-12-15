import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObjectContainer;
import flash.display.PixelSnapping;
import flash.display.Sprite;
import flash.geom.Rectangle;
import flash.geom.Point;
import haxe.ds.GenericStack.GenericStack;
import mt.deepnight.Key;

import volute.*;
import volute.postfx.Bloom;


import haxe.ds.Vector;
import haxe.ds.IntMap;
import haxe.ds.StringMap;
import haxe.EnumFlags.EnumFlags;
import mt.deepnight.Buffer;
import mt.DepthManager;
import volute.MathEx;

using volute.Ex;
enum CellFlags{
	BLOCK;
	WATER;
	SAND;
}

@:publicFields
class Level
{
	var colls : haxe.ds.Vector<EnumFlags<CellFlags>>;
	
	var store : Vector<Entity>;
	var storeCur : Int = 0;
	
	var view : DisplayObjectContainer;
	var root : flash.display.Sprite;
	
	var nbch :Int;
	var nbcw :Int;
	var cw = 16;
	var ch = 16;
	var buffer : Buffer;
	var hero : Hero;
	
	public static var I = 0;
	public static var DM_BG = I++;
	public static var DM_OPP = I++;
	public static var DM_CHAR = I++;
	public static var DM_BULLET = I++;
	public static var DM_TREE = I++;
	
	public inline static var SHIFT_X = 6;
	public inline static var MAX_X = 1 << SHIFT_X;
	public inline static var MAX_Y = 1024;
	
	public inline static var MAX_ENT = 1024;
	
	var dm : DepthManager;
	var bg : Bitmap;
	
	var bloom : Bloom;
	
	var bullets : Vector<Bullet>;
	var bulletCur : Int = 0;
	
	var collList : Vector<Int>;
	var nbColls : Int = 0;
	var radix:IntRadix;
	
	public function new( szx, szy ) {
		nbcw = szx;  nbch = szy; 
		store = new Vector(512);
		view = new Sprite();
		bullets = new Vector(512);
		
		colls = new Vector(1024<<SHIFT_X);
		for ( i in 0...szx * szy)
			colls[i] = EnumFlags.ofInt(0);
		
		root = new Sprite();
		
		view.addChild(root);
		dm = new DepthManager(root);
		
		for ( i in 0...I) dm.getPlan(i);
		
		dm.add( makeBg(), DM_BG );
		
		collList = new Vector( MAX_ENT );
		nbColls = 0;
		
		var np = nextPow2(nbch);
		radix = new IntRadix( MAX_ENT, nextPow2(nbch));
		trace("radix bit:"+np);
	}
	
	function nextPow2(x:Int)
	{
		var logbase2 = Math.log(x) / Math.log(2);
		return Std.int(Math.pow(2, Math.ceil(logbase2)));
	}
	
	public function postInit() {
		
		hero = new Hero();
		add( hero );
		
		var fl = EnumFlags.ofInt(0);
		fl.set( BloomFlags.FULLSCREEN);
		//fl.set( BloomFlags.BLOOM_ONLY);
		
		bloom = new Bloom(view, fl);
		bloom.setBlurFactors( 10 , 2 );
		bloom.nbPowPass = 3;
		bloom.rtRes = 0.5;
		bloom.upscale = 2;
		
		bloom.bmpResult.alpha = 0.75; 
		
		
		startGame();
	}
	
	public function getRender()
	{
		return view;
	}
	
	public function makeBg() {
		var t : Dynamic = M.me.data.getTiles();
		var gfx = M.me.data.getBg();
		var th  = t.tileheight;
		var tw  = t.tilewidth;
		
		var gfxw = Math.round(gfx.width/tw);
		var gfxh = Math.round(gfx.height/th);
		
		var bgw =  Std.int(t.layers[0].width * tw);
		var bgh =  Std.int(t.layers[0].height* th);
		
		bg = new Bitmap( new BitmapData( bgw,bgh, false,0xFFffffff) , PixelSnapping.NEVER, false);
		var bmd = bg.bitmapData;
		
		for ( y in 0...nbch) {
			for ( x in 0...nbcw ) {
				var ti : Int = t.layers[0].data[x + y * nbcw]-1;
				
				var tcx = ti % gfxw;
				var tcy = Std.int(ti / gfxw);
				
				bmd.copyPixels( gfx,
					new Rectangle(tcx* tw, tcy * th,tw,th),
					new Point(x * tw, y * th), null, null, false );
			}
		}
			
		return bg;
	}
	
	public inline function mkKey(cx, cy){
		return (cy<<SHIFT_X) | (cx);
	}
	
	public function dynTest(cx, cy, me){
		for ( e in store ) {
			if ( me != e && e.cx == cx && e.cy == cy )
				return e;
		}
		return null;
	}
	
	public inline function staticTest(cx, cy) {
		if ( cx < 0) return true;
		if ( cx >= nbcw) return true;
		
		if ( cy < 0) return true;
		if ( cy >= nbch) return true;
		
		return colls[mkKey(cx, cy)].has( BLOCK );
	}
	
	public function add(e:Entity){
		var nk = mkKey(e.cx, e.cy);
		store[storeCur++] = e;
		e.idx = storeCur - 1;
		dm.add( e.el , e.depth);
	}
	
	
	public function remove(e:Entity){
		store[e.idx] = store[storeCur - 1];
		store[e.idx].idx = e.idx;
		e.idx = -1;
	}
	
	
	public function update() {
		input();
		
		var i = storeCur - 1;
		var el = null;
		
		while (i >= 0) {
			el = store[i];
			el.update();
			if( !el.dead )
				i--;
		}
		
		var ic = 0;
		for ( i in 0...storeCur)
			collList[i] = el.cy | (i<<10);
			ic++;
			
		nbColls = i;
		
		radix.sortVector(collList,nbColls);
		
		tickBullets();
		cameraFollow();
		
		if( bloom != null)
			bloom.update(0.0);
	}
	
	public function tickBullets() {
		var bl = null;
		for ( i in 0...bulletCur )  bullets[i].update();
		
		
		for( i in 0...4) {
			for ( i in 0...bulletCur )  { 
				bl = bullets[i];
				bl.x += bl.dx * 0.25; 
				bl.y += bl.dy * 0.25; 
			}
			
			/*
			var j = bulletCur - 1;
			var idx;
			var cy; 
			var e;
			var bl;
			while( j>=0){
				bl = bullets[j];
				
				for (k in collList) {
					idx = k >> 10;
					cy = k & ((1 << 10) - 1);
					e = store[idx];
					
					if ( e.cy - (bl.cy) < -3 )
						continue;
						
					if ( e.cy - (bl.cy) > 3 )
						break;
						
					if( 1<<e.type.index() & bl.harm != 0 ) 
						e.tryCollideBullet( bl );
				}
				
				if ( bl.remove ) {
					if( bulletCur>1){
						bullets[j] = bullets[bulletCur - 1];
						bullets[bulletCur - 1] = null;
						bulletCur--;
						bl.kill();
					}
				}
				j--;
			}
			*/
		}
		
		for ( i in 0...bulletCur ) {
			bl = bullets[i];
			bl.dx *= bl.fx;
			bl.dy *= bl.fy;
		}
	}
	
	public function kill() {
		for ( s in store)
			s.kill();
	}
	
	public function down(k) {
		return Key.isDown( k );
	}
	
	public function input() {
		
		var mdx = 0.2;
		var mdy = 0.2;
		
		#if debug
		if(Key.isDown( Key.SHIFT )){
			if ( down( Key.DOWN )) {
				view.y+=10;
			}
			
			if ( down( Key.UP )) {
				view.y-=10;
			}
		}
		else 
		#end
		{
			hero.input();
		}
	}
	
	public function startGame() {
		trace("gameStart");
		hero.cy = nbch - 2;
		hero.cx = nbcw >> 1;
		
		hero.syncPos();
	}
	
	public function cameraFollow() {
		
		var k = 0.51;
		view.y = k * view.y + (1-k) * (hero.el.y - ( Lib.h()*3>>2));
		
		if ( view.y <=0 ) {
			view.y = 0;
		}
		
		if ( view.y > nbch * cw - Lib.h() ) {
			view.y = nbch * cw - Lib.h();
		}
	}
	
	public function addBullet( b : Bullet ) {
		bullets[bulletCur++] = b;
		dm.add( b.spr, DM_BULLET );
	}
	
}