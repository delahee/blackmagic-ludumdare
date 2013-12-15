import volute.Dice;
import volute.t.Vec2;
import volute.t.Vec2i;
import volute.*;
import Char.CharState;

using volute.Ex;

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
	var instaShoot = false;
	public function new( et, origin ) 
	{
		name = "opp";
		dir = S;
		state = Idle;
		
		super();
		name = "opp";
		type = ET_OPP;
		nmyType = et;
		stateLife = Dice.roll(0, 30);
		lastTargets = new List();
		this.origin = origin;
		cx = origin.x;
		cy = origin.y;
		curTarget = new Vec2i();
		
		currentGun = new Gun(this);
		currentGun.maxBullets = 4;
		currentGun.maxCooldown = 5;
		currentGun.init();
	}
	
	public function getNearWaypoint()
	{
		var lev = M.me.level;
		var colls = M.me.level.colls;
		
		var l = new List();
		for ( y in cy - 1...cy + 2)
		for ( x in cx - 1...cx + 2){
			if ( x == cx && y == cy )
				continue;
			if (  colls[lev.mkKey(x,y)].has(WP_PATH) )
				l.push( new Vec2i( x, y ) );
		}
		return l;
	}
	
	public inline function getCell() {
		return M.me.level.colls[M.me.level.mkKey(cx, cy)];
	}
	
	public override function onStateChange(os:CharState,ns:CharState)
	{
		if ( os == ns ) return;
		switch(ns) {
			default:
			case Watch: 
				addMessage("I heard something!");
				stateLife += Dice.roll(0, 20);
		}
	}
	
	public function tickAi() {
		
		if ( hp == 0 ) return;
		
		var char = M.me.level.hero;
		
		var dChar = Math.abs( MathEx.sqrI(cy - char.cy) + MathEx.sqrI(cx - char.cx));
		var dAggro = 3 * 3;
		var dStop = 5 * 5;
		
		var tickAggro = switch(dir) {
			case N: cy >= char.cy;
			case S: cy <= char.cy;
			case E: cx >= char.cx;
			case W:	cx <= char.cx;
			
			case NE: cy >= char.cy && cx >= char.cx;
			case NW: cy >= char.cy && cx <= char.cx;
			case SE: cy <= char.cy && cx >= char.cx;
			case SW: cy <= char.cy && cx <= char.cx;
		};
		
		if ( tickAggro) {
			if ( dChar <= dAggro) state = Shoot;
			else if ( dChar <= dStop) state = Watch;
			else if( state == Shoot || state == Watch )  state = Idle;
		}
	
		switch(nmyType) {
			default: 
				switch(state) {
					
					case Watch:
						dx = 0;
						dy = 0;
						if ( stateLife >= 30) {
							if ( id & 1 == 0)  	dir = dir.next( Dir );
							else 				dir = dir.prev( Dir );
							stateLife = 0;
							
						}
					case Shoot:
						
					case Idle:
						if ( stateLife > 30) {
							lastTargets.clear();
							if ( curTarget == null) curTarget = new Vec2i();
							
							//is on waypoint
							if ( getCell().has(WP_PATH) ) {
								curTarget.set(cx, cy);
								state = Run;
								//trace('hooking path $cx $cy');
							}
							//else reach one
							else {
								curTarget.copy( origin );
								state = Run;
								//trace("getting to origin");
							}
						}
					case Run: {
						if ( curTarget == null) {
							state  = Idle;
							lastTargets.clear();
							//trace("getting back to idle");
						}
						else{
							if ( cx == curTarget.x && cy == curTarget.y 
								&& MathEx.isNear(rx, 0, 0.1)
								&& MathEx.isNear(ry, 0, 0.1)
							) {
								
								if ( getCell().has( WP_WAIT ) && stateLife <= 30) {
									dx = 0.0;
									dy = 0.0;
									return;
								}
								
								//change way point
								var wp = getNearWaypoint();
								if ( getNearWaypoint().length == 0 ) {
									state = Idle;
									curTarget.copy( origin );
									//trace('$cx $cy : no near waypoint...getting to origin (${curTarget.x},${curTarget.y})');
									return;
								}
								//trace("found " + wp);
								//trace("explored " + lastTargets);
								var cwp : Vec2i = null;
								for ( w in wp ) {
									
									var explored = false;
									if( lastTargets.length >0){
										for ( l in lastTargets )
											if ( l.x == w.x && l.y == w.y) {
												explored = true;
												break;
											}
									}
									
									if ( explored ) continue;
									else {
										cwp = w;
										break;
									}
								}
									
								//trace("requiring " + cwp);
								if ( cwp == null) {
									state = Idle;
									curTarget = null;
									lastTargets.clear();
									//trace("no unexplored waypoint...getting to origin");
									return;
								}
								
								curTarget.x = cwp.x;
								curTarget.y = cwp.y;
								
								lastTargets.push(new Vec2i(cx, cy) );
								//trace("new waypoint");
								stateLife = 0;
								tickAi();
							}
							else {
								var realx = curTarget.x * 16;
								var realy = curTarget.y * 16;
								//trace(curTarget + " <> cx:" + cx + " cy:" + cy + " rx:" + rx +" ry:" + ry);  
								var sp = 0.1;
								var diffX = realx - ((cx << 4) + rx*16.0);
								var diffY = realy - ((cy << 4) + ry*16.0);
								var lenDiff = Math.sqrt(diffX * diffX + diffY * diffY);
								
								if ( lenDiff <= 1.0 ) 
								{
									cx = curTarget.x;
									cy = curTarget.y;
									rx = ry = 0.0;
									dx = 0;
									dy = 0;
									//trace('sticking $dx $dy $diffX $diffY');
								}
								else 
								{
									var ddx = diffX / lenDiff * sp;
									var ddy = diffY / lenDiff * sp;
									
									dx = ddx;
									//if ( Math.abs(dx) > Math.abs(diffX)) dx = diffX;
										
									dy = ddy;
									//if ( Math.abs(dy) > Math.abs(diffY)) dy = diffY;
									//trace('advancing $lenDiff $ddx $ddy $diffX $diffY');
								}
							}
						}
					}
					
					
				}
				
			case Boss:
		}
		
		if ( state == Shoot)
			if( currentGun!= null)
				currentGun.fire();
	}
	
	public override function update() {
		super.update();
		
		var lev = M.me.level;
		var dhy = M.me.level.hero.cy - cy;
		
		//up discard
		//if ( dhy > 10 )
		//	#if debug el.alpha = 1.0; #end
		//	return;
		
		#if debug
		if ( dhy > 20 ) {
			#if debug el.alpha = 1.0; #end
			return;
		}
		#else 
		if ( dhy > (300>>4) || dhy < -10) {
			#if debug el.alpha = 1.0; #end
			return;
		}
		#end
			
		#if debug
		el.alpha = 0.5;
		#end
		
		tickAi();
		
		switch(nmyType) {
			case Boss: dir = S;
			default:rosace8();
		}
	}
	public override function syncDir(odir:Dir,ndir:Dir) {
		if ( ndir == null ) return;
		if ( odir == ndir ) return;
		
		super.syncDir(odir, ndir);
	}
	
	public override function onKill() {
		super.onKill();
		
		M.me.ui.addScore(10, 
		el.x - M.me.level.view.x - el.width * 0.5,
		el.y - M.me.level.view.y - el.height  );
	}
}