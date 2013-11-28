using volute.com.Ex;
import flash.display.Bitmap;
import mt.deepnight.Tweenie;
import flash.geom.Point;
import flash.geom.Rectangle;
import Ods;
enum Slice
{
	SL_H;
	SL_V;
}

class Peon extends Entity
{
	var spr : ElementEx;
	
	var ph : Array<{bmp:Bitmap,bl:fx.BloodLine}>;
	var slicing  = false;
	var pnjData : PnjData;
	var id :Int;
	static var uid = 0;
	
	public function new() 
	{
		super();
		type = ET_PEON;
		el = (spr = new ElementEx());
		
		M.data.mkChar( spr, "hero", "stand");
		gravity = true;
		id=uid++;
	}
	
	static var sp  = 0;
	public override function enterLevel(l)
	{
		super.enterLevel(l);
		Tools.assert( pnjData != null);
		
		el.putBehind(M.char.el);
		
		if ( pnjData.score == 1 ) 
			return;
		
		if( sp++ % 2 == 0)
			spr.scaleX = -1;
	}
	
	public function slice() : Bool
	{
		if (slicing) return false;
		slicing = true;
		
		M.char.score += pnjData.score;
		M.char.souls++;
		M.ui.reapScore( pnjData.score );
		var sig = pnjData.score < 0 ?'': '+';
		M.ui.mkMsg( sig+pnjData.score+"  " +pnjData.name + "... " + pnjData.desc);
		
		ph = [];
		var sl = Std.random(8)<4 ? SL_V : SL_H;
		
		var i = 0;
		for( p in 0...2 )
		{
			var b : flash.display.Bitmap = mt.deepnight.Lib.flatten( spr );
			var p0 = null;
			var p1 = null;
			var lr = false;
			var sepDur = 200;
			var alphaDur = 100;
			var stallDur = 100;
			
			var helh = el.height*0.5;
			var helw = el.width * 0.5;
			var sepWait = sepDur;
			
			switch(sl) {
				case SL_V:
					
					var r = switch(i)
					{
						case 0:lr = false;
						p0 = new Point( -el.width * 0.33,	-el.height);
						if(Std.random(8)<4)
						p0.subtract(new Point(0, 0));
						p1 = new Point(el.width*0.33, -el.height*0.5);
						new Rectangle(0, el.height * 0.5, el.width, el.height * 0.5); 
						case 1: lr = true;
						
						p0 = new Point(-helw+0+5,				-el.height + 15);
						p1 = new Point( -helw + el.width * 0.5 + 5,	-el.height + 15);
						new Rectangle(0, 0, el.width, el.height * 0.5); 
					};
					b.bitmapData.fillRect( r, 0);
					switch(i)
					{
						case 0: 
							//var t = M.tweenie.create( b, "x", b.x -30, TType.TEaseOut, sepDur);
							b.rotationZ = 20 + Std.random(20);
							var t = M.tweenie.create( b, "y", b.y -5, TType.TEaseOut, sepDur * 0.5 );
							
							haxe.Timer.delay(function()
							M.tweenie.create( b, "y", b.y+5, TType.TEaseIn, sepDur*0.5 ),sepDur>>1);
						case 1:
							//b.y += 5;
							//var t = M.tweenie.create( b, "y", b.y +10, TType.TEaseIn, sepDur);
					}
					sepWait = sepDur;
				case SL_H:
					p0 = new Point(0, -el.height);
					p1 = new Point(0, 0);
					
					var r =
					switch(i)
					{
						case 0:
						lr = true;
						new Rectangle(0, 0, el.width * 0.5, el.height); 
						
						case 1:
						lr = false;
						new Rectangle(el.width * 0.5, 0, el.width * 0.5, el.height); 
					}
					b.bitmapData.fillRect( r, 0);
					var mag = 5;
					switch(i)
					{
						case 0: 
							var t = M.tweenie.create( b, "x", b.x + mag, TType.TEaseIn, sepDur);
							t.onUpdateT = function(f)
							{
								p0.x = f*mag;
								p1.x = f*mag;
							};
						case 1: 
							var t = M.tweenie.create( b, "x", b.x - mag, TType.TEaseIn, sepDur);
							t.onUpdateT = function(f)
							{
								p0.x = - f*mag;
								p1.x = - f * mag;
								
							};
					}
			}
			haxe.Timer.delay(function() M.tweenie.create( b, "alpha", 0.2, TType.TEase, alphaDur) , sepWait+stallDur);
			haxe.Timer.delay(function() kill(), sepWait +stallDur +alphaDur);
			
			{
				var bline = new fx.BloodLine(spr, p0, p1, lr, 0.1);
				spr.addChild( b);
				ph.push( { bmp:b, bl: bline } );
				bline.nbFric = 0.9;
				bline.nbPerFrame = 40;
				bline.life = 8;
				bline.g = 0.5;
			}
			i++;
		}
		spr.graphics.clear();
		spr.stop();
		return true;
	}
	
	public override function kill()
	{
		super.kill();
		if (ph != null)
		{
			for (p in ph)	p.bmp.bitmapData.dispose();
			ph.clear();
		}
		if(l!=null)
			l.remove2(this);
	}
}