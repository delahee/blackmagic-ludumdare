import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.filters.BlurFilter;
import flash.filters.GlowFilter;
import haxe.Public;
import mt.gx.Pool;
import starling.display.Image;
import volute.Dice;
import volute.Lib;
import volute.t.Vec2;


using Lambda;
using volute.LbdEx;
using volute.ArrEx;

import Data;

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
	
	var img : starling.display.Image;
	var link  : Null<Aster>;
	
	var isFire:Bool;
	
	var grid: Grid;
	var scripted : Bool;
	var script : ScriptedAster;
	
	var cine(default, setCine) : Null<Cine>;
	
	var flare : Null<volute.algo.Pool<FlarePart>>;

	static var bmpFlare : BitmapData;
	static var bmpSun : BitmapData;
	
	static var guid : Int = 0;
	
	public var a(default, set_a) : Float;
	public function new(isFire = false, sz : Float = 32) {
		super();
		
		if ( bmpFlare == null) bmpFlare = new BmpFlare(0,0,false);
		if ( bmpSun == null) bmpSun = new BmpSun(0,0,false);
		
		this.isFire = isFire;
		this.sz = sz;
		a = 0;
		x = y = 0;
		
		scripted = true;
		guid++;
		
		compile();
	}
	
	var cineMc : starling.display.MovieClip;
	
	public function setCine(c:Cine){
		
		if ( c != null) {
			cineMc = Data.me.getMovie(c.sprite, 'idle');
			cineMc.x = x + c.ofsSprite.x;
			cineMc.y = y - img.height + c.ofsSprite.y;
			img.parent.addChild( cineMc );
			
			switch(c.type ) {default:
			case ELVIS:
				var np = x + 930;
				var ng =  starling.display.Image.fromBitmap( new Bitmap( Data.me.manor) );
				ng.pivotX = ng.width;
				ng.x = np;
				
				img.parent.addChild( ng );
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
			var col = isFire ? 0xFF0000 : 0x000020;
			g.beginFill( col);
			g.drawCircle( sz / 2.0, sz / 2.0, sz );
			g.endFill();
			
			bmp = Lib.flatten( shp );
			img = Image.fromBitmap( bmp );
			img.readjustSize();
			img.pivotX = img.width * 0.5;
			img.pivotY = img.height * 0.5;
		}
		else
		{
			img = Image.fromBitmap( new Bitmap(bmpSun) );
			//img.scaleX = img.scaleY = sz / 100;
			img.pivotX = img.width * 0.5;
			img.pivotY = img.height * 0.5;
			img.scaleX = img.scaleY = sz / 100;
		}
		
		if ( isFire ) {
			flare = new volute.algo.Pool(function() 
			{
				var img = new FlarePart(new Bitmap(bmpFlare));
				img.pivotX = img.width * 0.5;
				img.pivotY = img.height * 0.5;
				img.scaleX = img.scaleY = 0.333;
				return img;
			});
			flare.reserve( 20 );
		}
		
		return this;
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
		
		if ( isFire ) {
			
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
				img.parent.addChild( n );
				
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
					break;
				}
				
				var ca = Math.cos( p.a );
				var sa = Math.sin( p.a );
				p.x = x + ca * p.v;
				p.y = y + sa * p.v;
				
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















