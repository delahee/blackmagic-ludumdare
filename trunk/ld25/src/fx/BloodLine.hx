package fx;
import flash.display.Shape;
using volute.com.Ex;
class BloodShape extends Shape, implements haxe.Public
{
	var sx : Float;
	var sy : Float;
	var sz : Int;
}

class BloodLine extends Fx, implements haxe.Public
{
	var parent:flash.display.DisplayObjectContainer;
	var p0:flash.geom.Point;
	var p1:flash.geom.Point;
	var nbPerFrame = 8.0;
	var nbFric =  0.95;
	
	static var pointPool : volute.algo.Pool<BloodShape>;
	
	var mine : List<BloodShape>; 
	var lr : Bool;
	var sc :Float;
	var life  = 999;
	var g = 1.0;
	
	//var dbg : Shape;
	public function new(	mc : flash.display.DisplayObjectContainer, 
							p0:flash.geom.Point,
							p1:flash.geom.Point,
							leftRight:Bool, sc)
	{
		super();
		this.sc = sc;
		if (pointPool == null)
			pointPool = new volute.algo.Pool( function()
			{
				var sh = new BloodShape();
				var s = 1 + Std.random(3);
				var c = switch(Std.random(16))
				{
					default: 	0xFF0000;
					case 0 :0x005500; s>>=1;
					case 1 : 0xd69a5c;
					case 2 : 0xfb5959;
					case 3 : 0xffffff;
				}
				sh.graphics.beginFill( c );
				sh.sz = s;
				sh.graphics.drawRect(0,0,s,s);
				sh.graphics.endFill();
				return sh; 
			});
			
		//life = 30;
		this.parent = mc;
		lr = leftRight;
		
		this.p0 = p0;
		this.p1 = p1;
		mine = new List();
		//dbg = new Shape();
		//var gfx = dbg.graphics;
		//gfx.lineStyle(1, 0x00FF00);
		//gfx.moveTo(p0.x, p0.y);
		//gfx.lineTo(p1.x, p1.y);
		//parent.addChild(dbg);
	}
	
	public function rotX(x:Float, y:Float, a: Float): Float
		return x * Math.cos(a) - y * Math.sin(a)
	
	public function rotY(x:Float, y:Float, a : Float): Float
		return x * Math.sin(a) + y * Math.cos(a)
	
	public override function update()
	{
		life--;
		nbPerFrame *= nbFric;
		
		if( life > 0 )
		for ( i in 0...Std.int(nbPerFrame+0.5))
		{
			var dx = (p1.x - p0.x);
			var dy = (p1.y - p0.y);
			
			var ld = Math.sqrt(dx * dx + dy * dy);
			
			var r = Math.random();
			var rX = dx * r + p0.x;
			var rY = dy * r + p0.y;
			
			var ndx=0.0; var ndy=0.0; var ild=1.0;
			
			if ( ld > 0)
			{
				ild = 1.0 / ld;
				ndx = dx * ild;
				ndy = dy * ild;
			}
			else if ( dx == 0)
			{
				ndx = 1; dy = 0;
			}
			else
			{
				ndx = 0; dy = 1;
			}
			
			var nx = lr?-ndy:ndy;
			var ny = lr?ndx:-ndx;
			
			var s = pointPool.create();
			s.alpha = 1;
			s.scaleX = 1;
			s.scaleY = 1;
			s.x = rX;
			s.y = rY;
			
			var mx = 2.0;
			if ( Std.random(7) == 0)
				mx *= 4.0;
			if ( Std.random(4) == 0)
				mx *= 2.0;
			mx *= sc;
			s.sx = nx * mx;
			s.sy = ny * mx;
			
			parent.addChild( s );
			mine.add( s );
		}
		
		for ( p in mine )
		{
			p.sy += g * ( 0.2 + (p.sz * 0.05));
			p.x += p.sx;
			p.y += p.sy;
			
			p.alpha *= 0.93;
			p.scaleX *= 0.98;
			p.scaleY *= 0.98;
			if ( p.alpha <= 0.2 )
			{
				p.alpha = 0;
				p.detach();
				pointPool.destroy( p );
				mine.remove(p);
			}
		}
		
		var ok = nbPerFrame > 0.99;
		if (!ok) kill();
		return ok;
	}
	
	public function kill()
	{
		for ( p in mine)
			p.detach();
		pointPool.reset();
		mine = null;
	}
}