import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.DisplayObjectContainer;
import flash.display.PixelSnapping;
import flash.display.Shape;
import flash.display.Sprite;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.text.*;
import flash.filters.BevelFilter;
import flash.filters.GlowFilter;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.geom.Point;
import haxe.ds.GenericStack.GenericStack;
import haxe.Timer;
import mt.deepnight.Key;
import volute.t.Vec2i;

import volute.*;
import volute.postfx.Bloom;

import Types;
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
	DEEP_WATER;
	BUSH;
	
	ALARM;
	
	//WP_START;
	//sWP_END;
	WP_WAIT;
	WP_PATH;
	
	NMY_NORMAL;
	NMY_HEAVY;
	NMY_BOSS;
	
	BRIDGE;
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
	var chest : Chest;
	var objects : List<Dynamic>;
	
	public static var I = 0;
	public static var DM_BG = I++;
	public static var DM_BLOOD = I++;
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
	
	var blood : Bitmap;
	
	public function new( szx, szy ) {
		nbcw = szx;  nbch = szy; 
		store = new Vector(512);
		view = new Sprite();
		bullets = new Vector(512);
		objects = new List();
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
		
		var np = superiorBit(nbch);
		radix = new IntRadix( MAX_ENT, np);
		trace("radix bit:" + np);
		
		disc = new Shape();
		disc.graphics.beginFill(0xFF0000);
		disc.graphics.drawCircle( -4, -4, 8);
		disc.graphics.endFill();
		
		blood = new Bitmap( new BitmapData( nbcw * 16, nbch * 16, true, 0x0) );
		blood.alpha = 0.85;
		dm.add( blood, DM_BLOOD);
		//blood.filters = [ new GlowFilter(0, 1, 10, 10) ];
		//blood.filters = [ new BevelFilter(1,45,0xfff,0.5,0x070707,0.0,2,2) ];
	}
	
	var disc : Shape;
	
	function nextPow2(x:Int)
	{
		var logbase2 = Math.log(x) / Math.log(2);
		return Std.int(Math.pow(2, Math.ceil(logbase2)));
	}
	
	function superiorBit(x:Int)
	{
		var logbase2 = Math.log(x) / Math.log(2);
		return Math.ceil(logbase2);
	}
	
	public function postInit() {
		
		add( hero = new Hero() );
		add( chest = new Chest() );
		
		var fl = EnumFlags.ofInt(0);
		fl.set( BloomFlags.FULLSCREEN);
		//fl.set( BloomFlags.BLOOM_ONLY);
		
		bloom = new Bloom(view, fl);
		bloom.setBlurFactors( 8 , 1 );
		bloom.nbPowPass = 3;
		bloom.rtRes = 0.5;
		bloom.upscale = 2;
		
		bloom.bmpResult.alpha = 0.8; 
		
		startGame();
		
		write();
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
		
		//var i = 0;
		for ( i in 0...t.layers.length ) {
			var lay = t.layers[i];
			
			for ( y in 0...nbch) {
				for ( x in 0...nbcw ) {
					
					if( lay.type == "tilelayer"){
						var ti : Int = lay.data[x + y * nbcw]-1;
						
						var tcx = ti % gfxw;
						var tcy = Std.int(ti / gfxw);
						
						if( lay.visible )
							bmd.copyPixels( gfx,
								new Rectangle(tcx* tw, tcy * th,tw,th),
								new Point(x * tw, y * th), null, null, false );
							
						var tsp = t.tilesets[0].tileproperties;
						var fi =  Std.string(ti);
						if( Reflect.hasField( tsp, fi)){
							var obj : Dynamic = Reflect.field( tsp, fi );
							if ( obj != null) {
								for( o in Reflect.fields( obj ))
									onProp( o, Reflect.field(obj,o), x, y);
							}
						}
					}
				}
			}
		}
			
		return bg;
	}
	
	
	
	public function onObject(o) {
		objects.push( o );
	}
	
	public function onProp(name:String, val:String, cx:Int, cy:Int) {
		//trace('[$cx,$cy] $name : $val');
		name=StringTools.trim(name);
		val=StringTools.trim(val);
		switch(name) {
			case "coll":
				var e = Type.createEnum( CellFlags, val.toUpperCase());
				
				var k = mkKey(cx, cy);
				var src = colls[k];
				
				colls[mkKey(cx, cy)].set( e );
				
				if ( e == DEEP_WATER && !src.has(BRIDGE) ) 
					colls[mkKey(cx, cy)].set( BLOCK );
					
				if ( e == BRIDGE ) {
					colls[mkKey(cx, cy)].unset( BLOCK );
					colls[mkKey(cx, cy)].unset( DEEP_WATER );
				}
				
			case "waypoint": {
				var e = Type.createEnum( CellFlags, "WP_"+val.toUpperCase());
				colls[mkKey(cx, cy)].set( e );
				if ( e == WP_WAIT)
					colls[mkKey(cx, cy)].set( WP_PATH );
			}
			
			case "opp":
				var e = Type.createEnum( CellFlags, "NMY_"+val.toUpperCase());
				colls[mkKey(cx, cy)].set( e );
				colls[mkKey(cx, cy)].set( WP_PATH );
		}
	}
	
	public function makeObjects() {
		
		for (y in 0...nbch)
			for ( x in 0...nbcw)
			{
				var k = mkKey(x, y);
				var v = colls[k];
				
				if ( v.has(	NMY_NORMAL )) {
					var nmy = new Nmy(Normal,new Vec2i(x,y));
					add( nmy );
				}
				if ( v.has(	NMY_HEAVY )){
					var nmy = new Nmy(Heavy,new Vec2i(x,y));
					add( nmy );
				}
				if ( v.has(	NMY_BOSS )){
					var nmy = new Nmy(Boss,new Vec2i(x,y));
					add( nmy );
				}
			}
	}
	
	public function reset() {
		while( store[0] != null ) 
			remove(store[0]);
		
		add(hero);
		add(chest);
		
		makeObjects();
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
	
	public inline function staticTest(e:Entity,cx, cy) {
		if ( cx < 0) return true;
		if ( cx >= nbcw) return true;
		
		if ( cy < 0) return true;
		if ( cy >= nbch) return true;
		
		return colls[mkKey(cx, cy)].has( BLOCK );
	}
	
	public function add(e:Entity){
		var nk = mkKey(e.cx, e.cy);
		store[storeCur++] = e;
		if ( e.idx != -1 ) throw "already add";
		e.idx = storeCur - 1;
		dm.add( e.el , e.depth);
	}
	
	
	public function remove(e:Entity) {
		if ( e.idx < 0) return;
		
		if ( storeCur > 0) {
			var o = store[e.idx];
			store[e.idx] = store[storeCur - 1];
			store[e.idx].idx = e.idx;
			e.idx = -1;
			store[storeCur - 1] = null;
			storeCur--;
		}
		else {
			store[storeCur=0] = null;
		}
	}
	
	
	public function update() {
		var profiler = false;
		var t = Timer.stamp();
		input();
		
		var i = storeCur-1;
		var el = null;
		
		var te = Timer.stamp();
		while (i >= 0) {
			el = store[i];
			el.update();
			if( !el.dead )
				i--;
		}
		if(profiler)trace("ent:"+(Timer.stamp() - te));
		
		var tfill = Timer.stamp();
		for ( i in 0...storeCur){
			//trace(i + " idx:" + i +" cy:"+ store[i].cy);
			collList[i] = store[i].cy | (i << 10);
		}
		if(profiler)trace("fill:"+(Timer.stamp() - tfill));
			
		nbColls = storeCur;

		var t0 = Timer.stamp();
		radix.sortVector(collList, nbColls);
		if(profiler)trace("radix:"+(Timer.stamp() - t0));
		
		var t1 = Timer.stamp();
		tickBullets();
		if (profiler) trace("bullets:" + (Timer.stamp() - t1));
		
		cameraFollow();
		
		var t2 = Timer.stamp();
		if ( bloom != null) bloom.update(0.0);
		if(profiler)trace("bloom:"+(Timer.stamp() - t2));
			
		if(profiler)trace("total"+(Timer.stamp() - t));
	}
	
	public function tickBullets() {
		var bl = null;
		for ( i in 0...bulletCur )  bullets[i].update();
		
		
		var j = bulletCur - 1;
		var idx;
		var cy; 
		var e;
		var bl;
		var k =  0;
		var dy;
		
		for( i in 0...4) {
			for ( i in 0...bulletCur )  { 
				bl = bullets[i];
				bl.x += bl.dx * 0.25; 
				bl.y += bl.dy * 0.25; 
			}
			
			while( j>=0){
				bl = bullets[j];
				
				for (m in 0...nbColls) {
					k = collList[m];
					idx = k >> 10;
					cy = k & ((1 << 10) - 1);
					e = store[idx];
					dy = e.cy - bl.cy;
					
					//trace('cy:$cy<>bcy:${bl.cy}<>dy:$dy');
					if ( dy < -3 )
						continue;
						
					if ( dy > 3 )
						break;
						
					if ( (bl.harm  & (1 << e.type.index())) != 0 ) {
						//trace("trying");
						e.tryCollideBullet( bl );
					}
					
				}
				
				if ( bl.remove ) {
					
					if( bulletCur>=1){
						bullets[j] = bullets[bulletCur - 1];
						bullets[bulletCur - 1] = null;
						bulletCur--;
						bl.kill();
					}
				}
				j--;
			}
			
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
	
	public var bgm : SoundChannel;
	public function startGame() {
		
		reset();
		trace("gameStart");
		hero.cy = nbch - 2;
		hero.cx = 5;
		
		chest.cx = hero.cx;
		chest.cy = hero.cy-3;
		
		hero.syncPos();
		chest.syncPos();
		
		bgm = (new Healing().play(0, 1000));
		bgm.soundTransform = new SoundTransform(0.2);
		
		
		//bloodAt( hero.el.x, hero.el.y);
	}
	
	public function write() {
		
		
		function writeDown(msg, x, y) {
			var tf = new TextField();
			var tft = new TextFormat('arial',12,0x0);
			tf.setTextFormat( tf.defaultTextFormat = tft ); 
			tf.mouseEnabled = false;
			tf.selectable = false;
			tf.width = 100;
			tf.height = 30;
			tf.text = msg;
			tf.width = tf.textWidth + 5;
			tf.filters = [ new GlowFilter(0x706934, 0.5, 2, 2, 20) ];
			tf.alpha = 0.5;
			mat.identity();
			mat.translate( x, y );
			bg.bitmapData.draw( tf, mat,null,OVERLAY);
		}
		
		writeDown("press Arrow keys to move", hero.realX()- 50, hero.realY() - 20);
		
		writeDown("press [CTRL] to act", hero.realX(), hero.realY() - 100);
		writeDown("DON'T FORGET THE CHEST!", hero.realX() - 50, hero.realY() - 170);
		
		writeDown("Money is life ! Well... Literally !", hero.realX()-50, hero.realY() - 300);
	}
	
	var mat = new Matrix();
	public function bloodAt(x,y, smin=0.1,smax=0.3){
		mat.identity();
		mat.scale(Dice.rollF(smin,smax),Dice.rollF(smin,smax));
		mat.translate( x, y);
		
		blood.bitmapData.draw( disc, mat, null, BlendMode.ADD );
	}
	
	public var isBottom = false;
	public function cameraFollow() {
		
		var k = 0.51;
		var target = hero.hasChest ? hero : chest;
		view.y = Math.round( k * view.y + (1-k) * (target.el.y - ( Lib.h()*3>>2)));
		view.x = Math.round(k * view.x + (1-k) * (target.el.x - ( Lib.w()>>1)));
		
		if ( view.y <=0 ) {
			view.y = 0;
		}
		
		isBottom = true;
		if ( view.y > nbch * cw - Lib.h() ) {
			view.y = nbch * cw - Lib.h();
			isBottom = false;
		}
		
		if ( view.x <=0 ) {
			view.x = 0;
		}
		
		if ( view.x >=  320 - 240 ) {
			view.x = 320-240;
		}
	}
	
	public function addBullet( b : Bullet ) {
		bullets[bulletCur++] = b;
		dm.add( b.spr, DM_BULLET );
	}
	
}