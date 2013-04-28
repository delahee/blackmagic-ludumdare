import flash.Lib;
import flash.Vector;
import mt.deepnight.Key;
import mt.gx.math.Vec2i;
import starling.display.MovieClip;
import starling.display.Sprite;
import volute.t.Vec2;
import volute.MathEx;

import volute.Types;
enum PlayerState {
	
	SPACED; //player wanders through infinite
	ASTER;
	RUN;
	JUMP;
	LAND;
}

class Player implements haxe.Public{
	var mc : MovieClip;
	var aster : Aster;
	
	//foot pos
	var pos : Vec2;
	var vel : Vec2;
	
	var state : PlayerState;
	
	var myAster : Null<Aster>;
	var myEdge : Null<Int>;
	var edgeFactor : Null<Float>;
	
	public function new() {
		mc = new MovieClip( Data.me.getFramesRectTex( 'perso', 'idle' ));
		pos = new Vec2();
		vel = new Vec2();
	}
	
	//find nearest nearest vertex then try to find a pos / edge factor
	/*
	public static function putOnAster( aster : Aster , inPos) : Null<{aster:Aster, edgeIdx:Int,edgeFactor:Float, outPos : Vec2, masterVtx:Vec2}>
	{
		var max : { idx : Null<Int>, dist: Float } = { idx:null, dist:2000.0*2000 };
		var res = new Vec2();
		
		for ( i in 0...aster.rotVtx.length) {
			var re = aster.getVtxRotGlb(i);
			var dst2 = Vec2.dist2( inPos, re );
			if ( max.idx == null)
				{ max.idx = i; max.dist = dst2;  }
			else{
				if ( dst2 < max.dist )	
					{ max.idx = i; max.dist = dst2; }
			}
		}
		
		volute.Lib.assert( max.idx != null);
		
		var nv = aster.getVtxRotGlb(max.idx);
		
		if ( max.dist <= 1.0 ){
			res.x = nv.x;
			res.y = nv.y;
			
			trace('vtx overlapse');
			//fixme
			return {aster:aster, edgeIdx : MathEx.posMod(max.idx + 1, aster.rotVtx.length),  edgeFactor:0,outPos:res,masterVtx:nv };
		}
		
		
		#if debug 
		//res.x = nv.x;
		//res.y = nv.y;
		//return { aster:null, edgeFactor:0, edgeIdx: 0,outPos:res,masterVtx:res };
		#end
		
		var pnv = aster.getVtxRotGlb(MathEx.posMod(max.idx-1, aster.rotVtx.length));
		var nnv = aster.getVtxRotGlb(MathEx.posMod(max.idx+1, aster.rotVtx.length));
		
		var nv_pos 	= new Vec2( inPos.x - nv.x, inPos.y - nv.y );
		var nv_p 	= new Vec2( pnv.x - nv.x, pnv.y - nv.y );
		var nv_n 	= new Vec2( nnv.x - nv.x, nnv.y - nv.y );
		
		var nv_posN = nv_pos.clone().normalize();
		var nv_pN = nv_p.clone().normalize();
		var nv_nN = nv_n.clone().normalize();
		
		var sig_nv_n = Vec2.signedArea( inPos.clone().normalize(), nv.clone().normalize(), nnv.clone().normalize() );
		var sig_nv_p = Vec2.signedArea( pnv.clone().normalize(), inPos.clone().normalize(), nv.clone().normalize()  );
		
		var e = null;
		var p = null;
		
		var acn = Math.acos( sig_nv_n );
		var acp = Math.acos( sig_nv_p );
		
		if ( acn < Math.PI   )
		{
			e = nv_n;
			p = Vec2.clampedProject(
		}
		else {
			e = nv_p;
			p = Vec2.clampedProject(
		}
	}
	*/
	
	public function getAsterPos() : Null<Vec2> {
		if ( aster == null ) 		return null;
		if ( myEdge == null ) 		return null;
		if ( edgeFactor == null ) 	return null;
		
		var e = myAster.rotEdges[myEdge];
		var p = Vec2.lerp( e.inv, e.outv, edgeFactor);
		
		return p;
	}
	
	/*
	public function getAsterNormal() : Null<Vec2> {
		if ( aster == null ) 		return null;
		if ( myEdge == null ) 		return null;
		if ( edgeFactor == null ) 	return null;
		
		var e = aster.edges[myEdge];
		var p = 
	}
	*/
	
	public function syncPos() {
		mc.x = pos.x;
		mc.y = pos.y;
	}
	
	public function update() {
		switch(state) {
			case ASTER:
			var p = getAsterPos();
			//var n = getAsterNormal();
			default:
		}
		
	}
}