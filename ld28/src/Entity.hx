import flash.display.Sprite;
import flash.display.Shape;
import flash.filters.GlowFilter;
import mt.deepnight.Tweenie.*;
import mt.deepnight.Tweenie.TType;
import volute.Coll;
import volute.Time;
import volute.Dice;

using volute.Ex;

enum ENT_TYPE
{
	ET_NONE;
	ET_PLAYER;
	ET_OPP;
	ET_CHEST;
	
	ET_CADAVER;
}

@:publicFields
class Entity 
{
	var el : flash.display.DisplayObject;
	
	var cx : Int = 0;
	var cy : Int = 0;
	
	var rx : Float = 0.0;
	var ry : Float = 0.0;
	
	var dx : Float = 0.0;
	var dy : Float = 0.0;
	
	var ofsX : Float = 0.0;
	var ofsY : Float = 0.0;
	
	var fx = 0.80;
	var fy = 0.80;
	
	var type:ENT_TYPE;
	
	var l : Level;
	
	var depth : Int;
	var name: String;
	
	var dead : Bool;
	
	static var uid = 0;
	var id = uid++;
	var idx :Int;
	
	var hp = 1;
	public function new() {
		type = ET_NONE;
		l = M.me.level;
		name = "entity#" + id;
		dead = false;
		idx = -1;
	}

	public function detach()
	{
		el.detach();
		l.remove(this);
	}
	
	public inline function realX() : Float return ((cx << 4) + rx * 16.0);
	public inline function realY() : Float return ((cy << 4) + ry * 16.0);
	
	public function customTest(cx, cy) {
		return false;
	}
	
	public inline function test(cx, cy)
	{
		if ( type == ET_PLAYER )
			if ( customTest(cx, cy) )
				return true;
				
		return l.staticTest(this,cx, cy);
	}
	
	public function updateX()
	{
		var moved = false;
		function m() moved = true;
		
		while (rx > 1) {
			
			if (!test(cx + 1, cy)){
				rx--;
				cx++;
				
				moved = true;
			}
			else{
				rx -= 0.05;
				dx = 0;
				
				moved = true;
			}
		}
		
		while (rx < 0){
			if (!test(cx -1, cy)){
				rx++;
				cx--;
				
				moved = true;
			}
			else{
				rx += 0.05;
				dx = 0;
				
				moved = true;
			}
		}
		
		return moved;
	}
	
	
	public function updateY()
	{
		var moved = false;
		
		while (ry > 1){
			if (!test(cx , cy+1)){
				ry--;
				cy++;
				moved = true;
			}
			else{
				ry -= 0.05;
				dy = 0;
				moved = true;
			}
		}
		
		while (ry < 0){
			if (!test(cx , cy-1)){
				ry++;
				cy--;
				
				moved = true;
			}
			else{
				ry += 0.05;
				dy = 0;
				
				moved = true;
			}
		}
		
		return moved;
	}
	
	public function update(){
		rx += dx;
		ry += dy;
					
		if (  Math.abs( dx ) < 1e-3 )
			dx = 0;
			
		if (  Math.abs( dy ) < 1e-3 )
			dy = 0;
		
		
		var uy = updateY();
		var ux = updateX();
		
		while(ux||uy)
		{
			uy = updateY();
			ux = updateX();
		}
		
		syncPos();
		
		dx *= fx;
		dy *= fy;
		
		//if(dx!=0) el.scaleX = dx < 0 ? -1 : 1;
		
	}
	
	public function level() : Level{
		return M.me.level;
	}
	
	public inline function syncPos()
	{
		el.x = Std.int((cx << 4) + rx * 16.0) + ofsX;
		el.y = Std.int((cy << 4) + ry * 16.0) + ofsY;
		//trace(el.x + " " + el.y);
	}
		
		
	public function kill()
	{
		if (el != null) 
			el.detach();
		if( idx > 0 )
			l.remove(this);
	}
	
	public function onHurt() {
		for ( i in 0...2) {
			var s = new Shape();
			s.graphics.beginFill(0xFF0000);
			s.graphics.drawRect(-1,-1,3,3);
			s.graphics.endFill();
			s.alpha = 0.8;
			s.filters = [new GlowFilter(0xFF0000,  Dice.rollF(0.2,0.3), 3,3 )];
			s.x = el.x + Dice.rollF(-5,5);
			s.y = el.y-20 + Dice.rollF(-10,10);
			var t = M.me.tweenie.create(s,"x",el.x + Dice.rollF(-10,10),TType.TBurnOut,250);
			var t = M.me.tweenie.create(s, "y", el.y + Dice.rollF(20,30) , TType.TBurnOut, 250);
			level().dm.add( s, Level.DM_BULLET);
			t.onEnd = function() s.detach();
		}
		
		for ( i in 0...Dice.roll(2, 5)) {
			level().bloodAt( el.x +Dice.roll( -6, 6), el.y +Dice.roll( -3, 3) );
		}
	}
	
	public function onKill() {
		
		var sup = 1.0;
		for ( i in 0...12) {
			if (Dice.percent(50))
				sup = 2.0;
			var s = new Shape();
			s.graphics.beginFill(0xFF0000);
			s.graphics.drawRect(-1,-1,2,2);
			s.graphics.endFill();
			s.filters = [new GlowFilter(0xFF0000, Dice.rollF(0.3, 0.2), 2, 2 )]; 
			
			var sd = Dice.toss();
			s.x = el.x + (sd?-1:1) * Dice.rollF(0,10);
			s.y = el.y-20 + Dice.rollF(-10,10);
			var t = M.me.tweenie.create(s,"x",el.x + sup * (sd?-1:1) * Dice.rollF(0,10),TType.TBurnIn,250);
			var t = M.me.tweenie.create(s, "y", el.y + sup * Dice.rollF(-8,16) , TType.TBurnOut, 350);
			level().dm.add( s, Level.DM_BULLET);
			t.onEnd = function() s.detach();
		}
		
		for ( i in 0...Dice.roll(10, 20)) {
			level().bloodAt( el.x +Dice.roll( -10, 10), el.y +Dice.roll( -5, 5),0.33,0.8 );
		}
		
		type = ET_CADAVER;
		
		M.me.timer.delay(function()
		{
			kill();
		}, 10);
	}
	
	public function tryCollideBullet(b:Bullet) {
		if ( b.remove) return;
		
		var t = Coll.testCircleRectAA(	b.headX(), b.headY(), b.headRadius(),
										el.x, el.y, el.width, el.height);
		if ( t ) {
			trace( "collided" );
			hp--;
			if ( hp <= 0 ) {
				onKill();
			}
			else 
				onHurt();
			b.remove = true;
		}
	}
}