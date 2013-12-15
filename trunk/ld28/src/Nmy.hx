import volute.Dice;
import volute.t.Vec2;
import volute.t.Vec2i;
import volute.*;


enum NmyType {
	Normal;
	Heavy;
	Boss;
}


class Nmy extends Char {
	
	var nmyType : NmyType;
	var curTarget : Vec2i;
	
	var lastTargets : List < Vec2i >;
	var origin : Vec2i;
	
	public function new( et, origin ) 
	{
		super();
		name = "opp";
		type = ET_OPP;
		nmyType = et;
		stateLife = Dice.roll(0, 30);
	}
	
	public function getNearWaypoint()
	{
		var lev = M.me.level;
		var colls = M.me.level.colls;
		
		var l = new List();
		for ( y in cy - 1...cy + 1)
		for ( x in cx - 1...cx + 1){
			if ( x == cx && y == cy )
				continue;
			if (  colls[lev.mkKey(cx,cy)].has(WP_PATH) )
				l.push( new Vec2i(x, y ) );
		}
		return l;
	}
	
	public inline function getCell() {
		return M.me.level.colls[M.me.level.mkKey(cx, cy)];
	}
	
	public override function update() {
		super.update();
		
		var lev = M.me.level;
		var dhy = M.me.level.hero.cy - cy;
		
		//up discard
		if ( dhy > 20 )
			return;
			
		if ( dhy < -4)
			return;
		
		switch(nmyType) {
			default: 
				switch(state) {
					default:
					case Idle:
						if ( stateLife > 30) {
							//is on waypoint
							if ( getCell().has(WP_PATH) ) {
								curTarget = new Vec2i(cx, cy);
								state = Run;
								trace("hooking path");
							}
							//else reach one
							else {
								curTarget = origin;
								state = Run;
								trace("getting to origin");
							}
						}
					case Run: {
						if ( curTarget == null) {
							state  = Idle;
							lastTargets.clear();
							trace("getting back to idle");
						}
						else{
							if ( cx == curTarget.x && cy == curTarget.y 
								&& MathEx.isNear(rx, 0.5, 0.1)
								&& MathEx.isNear(ry, 0.5, 0.1)
							) {
								//change way point
								var wp = getNearWaypoint();
								var cwp = null;
								for ( w in wp )
									for ( l in lastTargets )
										if ( l.x == w.x && l.y == w.y)
											continue;
										else {
											cwp = l;
											break;
										}
								
								curTarget.x = cwp.x;
								curTarget.y = cwp.y;
								
								lastTargets.push(new Vec2i(cx, cy) );
								trace("new waypoint");
							}
							else {
								var realx = curTarget.x * 16;
								var realy = curTarget.y * 16;
								var sp = 0.2;
								var diffX = realx - ((cx << 4) + rx);
								var diffY = realy - ((cy << 4) + ry);
								var lenDiff = Math.sqrt(diffX * diffX + diffY * diffY);
								
								if ( lenDiff == 0 ) throw "assert";
								
								var ddx = diffX / lenDiff * sp;
								var ddy = diffY / lenDiff * sp;
								
								dx += ddx;
								if ( Math.abs(dx) > diffX) dx = diffX;
									
								dy += ddy;
								if ( Math.abs(dy) > diffY) dy = diffY;
								trace("advancing");
							}
						}
					}
				}
				
			case Boss:
		}
		
		switch(nmyType) {
			case Boss: dir = S;
			default:rosace4();
		}
	}
	
	public override function onKill() {
		super.onKill();
		
		M.me.ui.addScore(10, 
		el.x - M.me.level.view.x - el.width * 0.5,
		el.y - M.me.level.view.y - el.height  );
	}
}