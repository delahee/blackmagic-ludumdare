import flash.display.Shape;
import flash.filters.GlowFilter;
import mt.deepnight.Tweenie;
import mt.deepnight.Tweenie.*;
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
		hp = 2;
		type = ET_OPP;
		nmyType = et;
		stateLife = Dice.roll(0, 30);
		lastTargets = new List();
		this.origin = origin;
		cx = origin.x;
		cy = origin.y;
		curTarget = new Vec2i();
		
		currentGun = new Gun(this);
		currentGun.maxBullets = 10;
		currentGun.maxCooldown = 4;
		currentGun.reloadCdFactor = 10;
		currentGun.init();
	}
	
	public function getNearWaypoint()
	{
		var lev = M.me.level;
		var colls = M.me.level.colls;
		
		var l = new List();
		for ( y in cy - 1...cy + 2)
		for ( x in cx - 1...cx + 2) {
			if ( y < 0 ) continue;
			if ( x < 0 ) continue;
			
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
	
	public function getHeroQuadrant() :Dir {
		var char = M.me.level.hero;
		var q = 3;
		
		var d = Math.PI - Math.atan2( cy - char.cy, cx - char.cx );
		return angleToDir(d);
	}
	
	
	public function tickAi() {
		
		if ( hp <= 0 ) return;
		
		var char = M.me.level.hero;
		
		var dChar = Math.abs( MathEx.sqrI(cy - char.cy) + MathEx.sqrI(cx - char.cx));
		var dAggro = 5 * 5;
		var dStop = 7 * 7;
		
		var q = getHeroQuadrant();
		var tickAggro = (dir == q || dir.next(Dir) == q || dir.prev(Dir) == q );
		
		if ( tickAggro && state != Hit) {
			if ( dChar <= dAggro) state = Shoot;
			else if ( dChar <= dStop) state = Watch;
			else if( state == Shoot || state == Watch )  state = Idle;
		}
	
		switch(nmyType) {
			default: 
				switch(state) {
					case Hit:
						if ( stateLife >= 30) {
							state = Idle;
						}
					
					case Watch:
						dx = 0;
						dy = 0;
						if ( stateLife >= 30) {
							if ( id & 1 == 0)  	dir = dir.next( Dir );
							else 				dir = dir.prev( Dir );
							stateLife = 0;
							
						}
					case Shoot:
						if ( stateLife >= 20 ) {
							
							if( Dice.percent(10))
								Dice.toss() ? dir = dir.next( Dir ) : dir = dir.prev( Dir );
							else 
							if ( Dice.percent(80))
								dir =  getHeroQuadrant();
							stateLife = 0;
						}
						
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
				if ( currentGun.fire() )
					isShooting = Char.shootCooldown;
					
		
	}
	
	public override function update() {
		super.update();
		
		if ( hp <= 0 ) return;
		
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
	public override function syncDir(odir:Dir, ndir:Dir) {
		
		if ( state == Hit ) return;
		
		isRunning = !(MathEx.is0( dx ) && MathEx.is0( dy ));
		
		if ( ndir == null) ndir = odir;
		
		if ( isShooting >= 0)
			bsup.playAnim("opp_shoot_" + Std.string(ndir).toLowerCase());
		else {
			bsup.playAnim("opp_shoot_" + Std.string(ndir).toLowerCase());
			bsup.stopAnim(0);
		}
		
		var verb = isRunning?"run":"idle";
		
		var f = 
		switch(ndir) {
			case N, NE, NW: 'opp_${verb}_n';
			case S, SE, SW: 'opp_${verb}_s';
				
			case E: 'opp_${verb}_e';
			case W: 'opp_${verb}_w'; 
		}
		var a = bsdown.playAnim(f);
		if ( !a) throw "no such anim "+f;
		
		super.syncDir(odir, ndir);
	}
	
	public override function onHurt() {
		super.onHurt();
		dir = getHeroQuadrant();
		addToMajorDir(dir, -0.5);
		addScore( 25 );
		state = Hit;
		bsup.playAnim( "opp_hit", 1);
		
		
	}
	
	public override function onKill() {
		super.onKill();
		
		addScore( 50 );
	}
}