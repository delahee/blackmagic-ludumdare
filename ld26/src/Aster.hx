import flash.display.Bitmap;
import flash.display.Shape;
import flash.filters.BlurFilter;
import flash.filters.GlowFilter;
import haxe.Public;
import starling.display.Image;
import volute.Dice;
import volute.Lib;
import volute.t.Vec2;

import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

using Lambda;
using volute.LbdEx;
using volute.ArrEx;


class Aster extends Entity, implements Public {
	var vtx : Array<{v:Vec2,d:Float}>;
	var edges : Array<{ inv:Vec2,outv:Vec2}>;
	var rotEdges : Array<{ inv:Vec2,outv:Vec2}>;
	var rotVtx : Array<Vec2>;
	
	var shp : flash.display.Shape; 
	var bmp : Bitmap; 
	
	var img : starling.display.Image;
	var link  : Null<Aster>;
	
	var isFire:Bool;
	var sz:Float;
	
	var grid: Grid;
	
	public var a(default, set_a) : Float;
	
	
	public function move(ix, iy) {
		x = ix; y = iy;
		syncPos();
	}
	
	public function translate(ix, iy) {
		x += ix; y += iy;
		syncPos();
	}
	
	public function new(isFire = false, sz : Float = 32) {
		super();
		vtx = [];
		edges = [];
		rotEdges = [];
		rotVtx = [];
		this.isFire = isFire;
		this.sz = sz;
		a = 0;
		x = y = 0;
		
		rand().compile();
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
	
	public function enableTouch()
	{
		img.touchable = true;
		img.addEventListener( TouchEvent.TOUCH , function mup(e:TouchEvent)
		{
			trace('touched');
			var touch: Touch = e.touches[0];
			if(touch!=null){
				if(touch.phase == TouchPhase.BEGAN)
				{
				}
 
				else if(touch.phase == TouchPhase.ENDED)
				{
					var loc = touch.getLocation(img);
					trace("mup on " + loc );
				}
 
				else if(touch.phase == TouchPhase.MOVED)
				{
				}
			}
			
		});
		
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
		g.beginFill(isFire?0xf9ec1f:0x0);
		g.moveTo(vtx[0].v.x, vtx[0].v.y);
		
		var cx = .0, cy = .0;
		var last = vtx[0].v;
		rotVtx[0] = vtx[0].v.clone();
		
		for ( i in 1...vtx.length ) {
			var v = vtx[i].v;
			g.lineTo(v.x, v.y);
			cx += v.x;
			edges.push( { inv:last.clone(), outv:v.clone() } );
			rotEdges.push( { inv:new Vec2(), outv:new Vec2() } );
			rotVtx[i] = v.clone();
			last = v;
		}
		
		edges.push( { inv:last.clone(), outv:vtx[0].v.clone() } );
		rotEdges.push( { inv:new Vec2(), outv:new Vec2() } );
		g.endFill();
		
		if ( isFire ) shp.filters = [ new BlurFilter() ];
			
		bmp = Lib.flatten( shp );
		img = Image.fromBitmap( bmp );
		
		img.readjustSize();
	
		var ofs = isFire ? 2 : 0;
		img.pivotX = bmp.width * 0.5 + ofs;
		img.pivotY = bmp.height * 0.5 + ofs;
		
		return this;
	}
	
	public function getVtxRotGlb( i : Int ) {
		var dpx = img.pivotX;
		var dpy = img.pivotY;
		
		return  new Vec2( rotVtx[i].x + x - dpx, rotVtx[i].y + y - dpy);
	}
	
	public function getInEdgeRotGlb( i : Int ) {
		var dpx = img.pivotX;
		var dpy = img.pivotY;
		
		return  new Vec2( rotEdges[i].inv.x + x - dpx, rotEdges[i].inv.y + y - dpy);
	}
	
	public function getOutEdgeRotGlb( i : Int ) {
		var dpx = img.pivotX;
		var dpy = img.pivotY;
		
		return  new Vec2( rotEdges[i].outv.x + x - dpx, rotEdges[i].outv.y + y - dpy);
	}
	
	public function setPosXY(x,y) {
		if (grid != null && key != null)
			grid.remove( this );
		
		img.x = x;
		img.y = y;
		
		grid.add( this );
	}
	
	public function rand()
	{
		//var sect = Dice.roll( 5 , 8 );
		//var sect = Dice.roll( 3,4);
		var sect = 4;
		
		for ( i in 0...sect ){
			var x = 1;
			var y = 0;
			var a = (Math.PI*2/sect) * i;
			var cos = Math.cos(a);
			var sin = Math.sin(a);
			var d = Dice.rollF( sz, sz +  sz*0.25 );
			
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
	
	public function set_a(f:Float) {
		
		a = f;
		if ( img != null){
		
		img.rotation = f;
		for ( i in 0...edges.length) {
			var e = edges[i];
			rotEdges[i].inv.copy(e.inv.rotationPointXY( img.pivotX, img.pivotY,f ));
			rotEdges[i].outv.copy(e.outv.rotationPointXY( img.pivotX, img.pivotY, f ));
		}
		
		for ( i in 0...vtx.length) {
			var v = vtx[i];
			rotVtx[i].copy(v.v.rotationPointXY( img.pivotX, img.pivotY, f));
		}
		}
			
		return f;
	}
	
	public function syncPos()
	{
		img.x = x; img.y = y;
	}
	
	/**   a
	 *   /
	 *  /
	 * b----c
	 * 
	 * projects a on bc by b
	 */
	
	 
	public function projectConstant( a : Vec2, b : Vec2, c : Vec2 ) : Float {
		var ba = b.clone().decr( a );
		var bc = b.clone().decr( c );
		
		return ((ba.x * bc.y ) + (ba.y * bc.x)) / bc.norm2();
	}
	
	/*
	public function project( a : Vec2,b : Vec2,c : Vec2 ) : Vec2{
		var ba = b.clone().decr( a );
		var bc = b.clone().decr( c );
		
		var proj_k = projectConstant(a,b,c);
		
		return b.clone().incr(proj_k);
	}
	*/
	
	public function angle( a : Vec2,b : Vec2 ) : Float{
		var d = Vec2.dot( a , b );
		var cab = d / a.norm();
		return Math.acos( cab );
	}
	
	/**
	 * 
	 *   a
	 *  /
	 * /
	 * o------b
	 */
	public function clampedProject( a : Vec2, b : Vec2, theta : Float) : Vec2{
		var ca = Math.cos( theta ); 
		if ( theta < Math.PI / 2)
			return Vec2.ZERO.clone();
		else {
			var sc = a.length() * ca;
			if ( sc > b.length() )
				return b.clone();
			else 
				return b.clone().safeNormalize(Vec2.ZERO).mulScalar( sc );
		}	
	}
	
	public static function isInCone( va :Vec2, vb : Vec2, vo : Vec2) {
		va = va.clone().normalize();
		vb = vb.clone().normalize();
		vo = vo.clone().normalize();
		
		var vao = Vec2.angle( va, vo );
		var vab = Vec2.angle( va, vb );
		
		return vao <= vab && vao >= 0;
	}
	
	public function getGlbCenter()
	{
		var c = new Vec2( 0, 0 );
		for ( i in 0...rotEdges.length ) {
			var v = getInEdgeRotGlb(i);
			c.x += v.x;
			c.y += v.y;
		}
		c.x /= rotEdges.length;
		c.y /= rotEdges.length;
		
		return c;
	}
	
	public function getInterestingEdge( inPoint : Vec2 ) : Int
	{
		var c = getGlbCenter();
		
		for ( i in 0...rotEdges.length) {
			
			var ei = getInEdgeRotGlb(i);
			var eo = getOutEdgeRotGlb(i);
			
			var cin = c.clone().decr( ei );
			var cout = c.clone().decr( eo );
			
			if ( isInCone( cin, cout, inPoint ))
				return i;
		}
		
		return -1;
	}
	
	public function intersectAster( inPoint: Vec2 )
	{
		var ei = getInterestingEdge( inPoint );
		var e = rotEdges[ei];
		
		var a = inPoint.clone().decr( e.inv );
		var b = e.outv.clone().decr( e.inv );
		
		var theta = Vec2.angle( a.clone(), b.clone() );
		var clamp = Vec2.clampedProject( a, b, theta );
		
		return clamp;
	}
	
}















