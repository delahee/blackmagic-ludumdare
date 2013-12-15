import flash.display.Sprite;
import volute.Coll;
import volute.Time;

using volute.Ex;

enum ENT_TYPE
{
	ET_PLAYER;
	ET_OPP;
	
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
	
	public inline function test(cx, cy)
	{
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
		if(dx!=0)
			el.scaleX = dx < 0 ? -1 : 1;
		
	}
	
	public inline function syncPos()
	{
		el.x = Std.int((cx << 4) + rx * 16.0);
		el.y = Std.int((cy << 4) + ry * 16.0);
		
		//trace(el.x + " " + el.y);
	}
		
		
	public function kill()
	{
		if (el != null) el.detach();
		l.remove(this);
	}
	
	public function onHurt() {
		
	}
	
	public function onKill() {
		type = ET_CADAVER;
		
		M.me.timer.delay(function()
		{
			kill();
		}, 10);
	}
	
	public function tryCollideBullet(b:Bullet) {
		var t = Coll.testCircleRectAA(	b.headX(), b.headY(), b.headRadius(),
										el.x, el.y, el.width, el.height);
		if ( t ) {
			hp--;
			if ( hp == 0 ) {
				onKill();
			}
			else onHurt();
			b.remove = true;
		}
	}
}