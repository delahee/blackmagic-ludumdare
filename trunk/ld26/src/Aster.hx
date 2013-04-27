import flash.display.Bitmap;
import flash.display.Shape;
import haxe.Public;
import starling.display.Image;
import volute.Dice;
import volute.Lib;
import volute.t.Vec2;

using Lambda;
using volute.LbdEx;
using volute.ArrEx;


class Aster implements Public {
	var vtx : Array<{v:Vec2,d:Float}>;
	var edges : Array<{ inv:Vec2,outv:Vec2}>;
	var rotEdges : Array<{ inv:Vec2,outv:Vec2}>;
	var shp : flash.display.Shape; 
	var bmp : Bitmap; 
	
	var img : starling.display.Image;
	var link  : Null<Aster>;
	
	public var a(default, set_a) : Float;
	public function translate(x,y) {
		img.x += x; img.y += y;
	}
	
	public function new() {
		vtx = [];
		edges = [];
		rotEdges = [];
	}
	
	public function dispose() {
		bmp.bitmapData.dispose();
		bmp.bitmapData = null;
		bmp = null;
		vtx = null;
	}
	
	//vertex are ordered
	public function addVertex( v : Vec2 ) {
		vtx.push({v:v,d:v.norm()});
	}
	
	public function compile() {
		var max = null;
		for ( v in vtx )
			if ( max == null ) 
				max = v;
			else 
				if ( max.d < v.d ) 
					max = v;
					
		var minX = 5000.0;
		var minY = 5000.0;
		
		for ( v in vtx ) {
			if ( v.v.x < minX ) minX = v.v.x;
			if ( v.v.y < minY ) minY = v.v.y;
		}
		
		for ( v in vtx ) {
			v.v.x -= minX;
			v.v.y -= minY;
		}
		
		volute.Lib.assert( max != null );
		
		shp = new Shape();
		var g = shp.graphics;
		
		g.lineStyle();
		g.beginFill([0xFF00FF,0xFFFF00,0x00FFFF].random());
		g.moveTo(vtx[0].v.x, vtx[0].v.y);
		
		var cx = .0, cy = .0;
		var last = vtx[0].v;
		for ( i in 1...vtx.length ) {
			var v = vtx[i].v;
			g.lineTo(v.x, v.y);
			cx += v.x;
			
			trace('process vtx:' + v);
			edges.push( { inv:last.clone(), outv:v.clone() } );
			rotEdges.push( { inv:new Vec2(), outv:new Vec2() } );
			trace('output edge:' + edges.last());
			last = v;
		}
		edges.push( { inv:last.clone(), outv:vtx[0].v.clone() } );
		rotEdges.push( { inv:new Vec2(), outv:new Vec2() } );
		g.endFill();
		
		bmp = Lib.flatten( shp );
		img = Image.fromBitmap( bmp );
		
		var n = vtx.length;
		
		img.readjustSize();
		img.pivotX = bmp.width * 0.5;
		img.pivotY = bmp.height * 0.5;
		
		for ( i in 0...vtx.length) {
			var e = vtx[i];
			var dx = -img.pivotX;
			var dy = -img.pivotX;
			
			e.v.x += dx;
			e.v.y += dy;
		}
		
		
		//img.readjustSize();
		
		return this;
	}
	
	public function rand()
	{
		var sect = 4;
		for ( i in 0...sect ){
			var x = 1;
			var y = 0;
			var a = (Math.PI*2/sect) * i;
			var cos = Math.cos(a);
			var sin = Math.sin(a);
			var d = Dice.rollF( 50, 100 );
			
			var vx = d*(x * cos - y * sin);
			var vy = d*(y * cos + x * sin);
			var v = new Vec2(vx, vy);
			
			addVertex(v);
		}
		
		compile();
		set_a(0);
		
		
		return this;
	}
	
	public function update() {
		
	}
	
	public function set_a(f:Float){
		//img.rotation = f;
		for ( i in 0...edges.length) {
			var e = edges[i];
			//rotEdges[i].inv.copy(e.inv.rotationPointXY( img.pivotX, img.pivotY,f ));
			//rotEdges[i].outv.copy(e.outv.rotationPointXY( img.pivotX, img.pivotY,f ));
			
			//rotEdges[i].inv.copy( e.inv );
			//rotEdges[i].outv.copy( e.outv );
		}
		return f;
	}
}















