import flash.display.Bitmap;
import flash.display.Shape;
import starling.display.DisplayObjectContainer;
import starling.display.Image;
import starling.display.QuadBatch;
import starling.display.Sprite;

import volute.algo.Pool;
import flash.filters.GlowFilter;

import volute.Dice;
import Data;

using volute.Ex;

class Starfield {
	public var bmp : Bitmap;
	public var rep : Pool<Image>;
	public var spin = 10;
	public var root : Sprite;
	public var nb:Int;
	public var parent : DisplayObjectContainer; 
	public function new(p:DisplayObjectContainer, w:Float, h:Float, sc:Float = 1.0, nb:Int = 50) {
		
		parent = p;
		bmp = new Bitmap(new BmpStar(0, 0, false));
		rep = new Pool<Image>( function() {
			var i = Image.fromBitmap( bmp );
			i.blendMode = starling.display.BlendMode.ADD;
			i.scaleY = i.scaleX = Dice.rollF( 0.5, 1.0 ) * sc;
			i.alpha = 0.0;
			i.pivotX = i.width * 0.5; 
			i.pivotY = i.height * 0.5;
			//i.rotation += Dice.rollF(-0.1, 0.1);
			return i;
		});
		
		this.nb = nb;
		rep.reserve( nb );
		root = new Sprite();
		root.name = "starfield";
		for ( x in rep.getFree()) {
			var img = rep.create();
			img.x = volute.Dice.rollF(0, w);
			img.y = volute.Dice.rollF(0, h);
			root.addChild( img );
		}
		p.addChild(root);
	}
	
	public function update() {
		spin--;
		if ( spin <= 0) {
			spin = 3;
			var p = Player.me;
			for ( r in rep.getUsed()) {
				if ( Dice.percent( 20 ) )
					r.alpha = 0.4 + Dice.rollF( -0.1, 0.1 );
			}
		}
	}
	
	public function dispose()
	{
		if ( root != null) {
			root.detach();
			for ( p in rep.getAll()) p.dispose();
			rep.reset();
			parent = null;
			root.dispose();
			root = null;
			return true;
		}
		return false;
	}
}

