import haxe.Public;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.filters.BlurFilter;
import flash.filters.GlowFilter;

import starling.display.Image;
import starling.display.Sprite;

import volute.Dice;
import volute.Lib;
import volute.t.Vec2;

import Data;

using volute.Ex;



class FlarePart extends Image{
	public var life : Float;
	public var v : Float;
	public var a : Float;
	
	public function new ( bmp ) {
		var tex = starling.textures.Texture.fromBitmap( bmp);
		super( tex );
	}
}

class Aster extends Entity, implements Public {
	
	var shp : flash.display.Shape; 
	var bmp : Bitmap; 
	var img : Sprite;
	var base : starling.display.Image;
	var decal : starling.display.Image;
	var link  : Null<Aster>;
	
	var isFire:Bool;
	
	var grid: Grid;
	var scripted : Bool;
	var script : ScriptedAster;
	
	var cine(default, setCine) : Null<Cine>;
	
	var flare : Null<volute.algo.Pool<FlarePart>>;
	
	var decor : Array<Image>;

	static var bmdFlare : BitmapData;
	static var bmdSun : BitmapData;
	
	static var bmpFlare : Bitmap;
	static var bmpSun : Bitmap;
	
	static var guid : Int = 0;
	
	public var a(default, set_a) : Float;
	
	public var osz : Float;
	public function new(isFire = false, sz : Float = 32, ?scr) {
		super();
		
		if ( bmpFlare == null) 	{ bmdFlare = new BmpFlare(0, 0, false); 	bmpFlare = new Bitmap(bmdFlare); }
		if ( bmpSun == null) 	{ bmdSun = new BmpSun(0,0,false); 			bmpSun = new Bitmap(bmdSun); }
		
		img = new Sprite();
		this.isFire = isFire;
		this.sz = sz;
		a = 0;
		x = y = 0;
		
		scripted = true;
		guid++;
		
		decor = [];
		script = scr;
		osz = sz;
		compile();
	}
	
	var cineMc : starling.display.MovieClip;
	
	public function setCine(c:Cine){
		
		if ( c != null) {
			cineMc = Data.me.getMovie(c.sprite, 'idle');
			cineMc.readjustSize();
			cineMc.pivotX = cineMc.width * 0.5;
			cineMc.pivotY = cineMc.height;
			cineMc.x = c.ofsSprite.x;
			cineMc.y = - sz + c.ofsSprite.y;
			img.addChild( cineMc );
			
			switch(c.type ) {default:
			case ELVIS:
				var np = 1040;
				var ng =  starling.display.Image.fromBitmap( new Bitmap( Data.me.manor) );
				ng.pivotX = ng.width;
				ng.pivotY = ng.height*0.5;
				ng.x = np;
				ng.y = 10;
				
				img.addChild( ng );
				
				function getBiatch(){
					var mc = Data.me.getMovie('biatch', 'idle');
					mc.pivotX = mc.width * 0.5;
					mc.pivotY = mc.height;
					
					mc.x = np - 200;
					mc.y = 10;
					return mc;
				}				
				
				var b = getBiatch(); img.addChild( b );
				var b1 = getBiatch(); 
				b1.x += 30;
				b1.scaleY = 0.9;
				b1.y -= 5;
				b1.currentFrame++;
				b1.alpha = 0.98;
				img.addChild( b1 );
			}
		}
		
		return cine = c;
	}
	
	public function move(ix, iy) {
		x = ix; y = iy;
		syncPos();
		return this;
	}
	
	public function translate(ix, iy) {
		x += ix; y += iy;
		syncPos();
		return this;
	}
	
	public function dispose() {
		bmp.bitmapData.dispose();
		bmp.bitmapData = null;
		bmp = null;
	}
	
	public function compile() {
		
		if ( !isFire )
		{
			shp = new Shape();
			var g = shp.graphics;
			var col = 0x0;
			g.beginFill( col,1.0);
			g.drawCircle( sz / 2.0, sz / 2.0, sz );
			g.endFill();
			
			bmp = mt.deepnight.Lib.flatten( shp );
			base = Image.fromBitmap( bmp );
			base.readjustSize();
			base.pivotX = base.width * 0.5;
			base.pivotY = base.height * 0.5;
			
			
			{
				var isCp =  (script != null && script.isCheckpoint());
				
				decal = new Image( Data.me.getTex('planetes', 'idle', isCp ? 0 :Dice.roll( 1, 4 ) ));
				decal.readjustSize();
				decal.pivotX = decal.width * 0.5;
				decal.pivotY = decal.height * 0.5;
				decal.scaleX = decal.scaleY = sz / 100;
				decal.blendMode = starling.display.BlendMode.ADD;
				decal.rotation = Dice.rollF( 0, Math.PI * 2 );
				
				img.addChild( decal );
			}
			img.addChild( base );
		}
		else
		{
			base = Image.fromBitmap(bmpSun );
			base.pivotX = base.width * 0.5;
			base.pivotY = base.height * 0.5;
			base.scaleX = base.scaleY = sz / 100;
			img.addChild( base );
		}
		
		if ( isFire ) {
			flare = new volute.algo.Pool(function() 
			{
				var i = new FlarePart(bmpFlare);
				i.pivotX = i.width * 0.5;
				i.pivotY = i.height * 0.5;
				i.scaleX = i.scaleY = 0.333;
				return i;
			});
			flare.reserve( 20 );
		}
		
		return this;
	}
	
	public function getPosAtAngle(a){
		var c = getCenter();
		var r = sz - 2;
		
		var ca = Math.cos( a );
		var sa = Math.sin( a );
		
		return {	x:c.x + ca * r,
					y:c.y + sa * r };
	}
	
	private function setPosXY(x,y) {
		if (grid != null && key != null) grid.remove( this );
		
		img.x = x;
		img.y = y;
		
		if( grid != null ) grid.add( this );
	}
	
	public var spin = 0.;
	public function update() {
		var df = M.timer.df;
		
		var p = Player.me;
		var cull = volute.MathEx.dist2( p.pos.x, p.pos.y, img.x, img.y) > 1300 * 1300;
		img.visible = !cull; 
		
		if ( isFire && !cull) {
			
			spin += df;
			
			if ( spin > 2)
			{
				var n = flare.create();
				n.life = 60 + Dice.roll( 0,20);
				n.a = Dice.rollF( 0.0, 2 * Math.PI );
				n.v = (60 + Dice.roll( 0,20)) * sz / 100;
				n.x = x;
				n.y = y;
				n.scaleX = n.scaleY = 0.333;
				n.alpha = 1.0;
				n.blendMode = starling.display.BlendMode.ADD;
				
				n.visible = true;
				img.addChild( n );
				
				spin = 0;
			}
			
			
			for ( p in flare.getUsed())
			{
				p.life-= df;
				p.v += df;
				
				if ( p.life <= 0) {
					p.visible = false;
					flare.destroy( p );
					p.removeFromParent(false);
				}
				else
				{
					var ca = Math.cos( p.a );
					var sa = Math.sin( p.a );
					p.x = ca * p.v;
					p.y = sa * p.v;
					
					if( p.life >= 10)
						p.scaleX = p.scaleY += df * 0.01;
					else 
					{
						p.scaleX = p.scaleY *= 0.7;
						p.alpha -= 0.1 * df;
					}
				}
			}
				
		}
	}
	
	public function set_a(f:Float) {
		a = f;
		return f;
	}
	
	public function syncPos(){
		setPosXY( x, y );
	}
	
	public function getCenter() {
		return new Vec2(x,y);
	}
	
	public function intersects( a: Aster) {
		var ac = a.getCenter();
		var pos = getCenter();
		
		var c = pos.decr( ac );
		
		return a.sz * a.sz + sz * sz >= c.norm2();
	}
	
	public function onBurn()
	{
		
	}
	
}















