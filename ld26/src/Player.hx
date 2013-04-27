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
		//pos.x = nv.x;
		//pos.y = nv.y;
		//return;
		#end
		
		var pnv = aster.getVtxRotGlb(MathEx.posMod(max.idx-1, aster.rotVtx.length));
		var nnv = aster.getVtxRotGlb(MathEx.posMod(max.idx+1, aster.rotVtx.length));
		
		//which one please ? 
		var cv0 = Vec2.signedArea( inPos, nv , pnv); 
		var cv1 = Vec2.signedArea( inPos, nv , nnv); 
		
		var e = null;
		if ( cv0 < cv1 )	{ e = pnv; }
		else 				{ e = nnv; }
		
		var nv_pos = new Vec2( inPos.x - nv.x, inPos.y - nv.y );
		var nv_e = new Vec2( e.x - nv.x, e.y - nv.y );
		
		#if debug 
		//pos.x = e.x;
		//pos.y = e.y;
		//return;
		#end
	
		var proj_pos_k = ((nv_pos.x * nv_e.x ) + (nv_pos.y * nv_e.y)) / nv_e.norm2();
		var proj_pos = nv_e.clone();
		
		proj_pos.x *= proj_pos_k;
		proj_pos.y *= proj_pos_k;
		
		//myAster = aster;
		//edgeFactor = proj_pos_k;
		
		res.x = proj_pos.x + nv.x;
		res.y = proj_pos.y + nv.y;
		
		//fixme edge
		return { aster:aster, edgeFactor:proj_pos_k, edgeIdx: 0,outPos:res,masterVtx:nv };
	}
	
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