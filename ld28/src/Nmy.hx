import flash.display.Shape;
import flash.filters.GlowFilter;
import flash.Lib;
import flash.media.SoundChannel;
import haxe.Timer;
import mt.deepnight.Key;
import mt.deepnight.Tweenie;
import mt.deepnight.Tweenie.*;
import volute.Dice;
import volute.t.Vec2;
import volute.t.Vec2i;
import volute.*;
import Char.CharState;
import Types;
using volute.Ex;



class Nmy extends Char {
	
	var nmyType : NmyType;
	var curTarget : Vec2i;
	
	var lastTargets : List < Vec2i >;
	var origin : Vec2i;
	var instaShoot = false;
	var sp = 0.1;

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
		//ry++;
		//cy--;
		curTarget = new Vec2i();
		
		switch( et ) {
			case Normal:
			currentGun = new Gun(this);
			currentGun.maxBullets = 8;
			currentGun.maxCooldown = 4;
			currentGun.reloadCdFactor = 10;
			currentGun.init();
			
			case Heavy:
			currentGun = new Gun(this);
			currentGun.maxBullets = 120;
			currentGun.maxCooldown = 2;
			currentGun.reloadCdFactor = 30;
			currentGun.recoil *= 0.25;
			currentGun.init();
			hp = 10;
			sp = 0.05;
			
			case Boss:
			currentGun = new Gun(this);
			currentGun.maxBullets = 80;
			currentGun.maxCooldown = 1;
			currentGun.reloadCdFactor = 5;
			currentGun.recoil = 0;
			currentGun.spread = Math.PI / 6.0;
			currentGun.bulletLife = 100;
			currentGun.init();
			hp = 30;
			sp = 0.025;			
			aggroDist = 100;
		}
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
		if ( aggroDist != 0) dAggro = aggroDist*aggroDist;
		var dStop = 7 * 7;
		
		var q = getHeroQuadrant();
		var tickAggro = (dir == q || dir.next(Dir) == q || dir.prev(Dir) == q );
		
		if ( tickAggro && state != Hit) {
			if ( dChar <= dAggro) state = Shoot;
			else if ( dChar <= dStop) {
				state = Watch;
				if ( dir == getHeroQuadrant()) {
					dAggro = 7 * 7;
					dStop = 9 * 9;
				}
			}
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
								&& MathEx.isNear(rx, 0.5, 0.1)
								&& MathEx.isNear(ry, 0.5, 0.1)
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
								var realx = curTarget.x * 16 + 8;
								var realy = curTarget.y * 16 + 8;
								var diffX = realx - realX();
								var diffY = realy - realY();
								var lenDiff = Math.sqrt(diffX * diffX + diffY * diffY);
								
								if ( lenDiff <= 1.0 ) 
								{
									cx = curTarget.x;
									cy = curTarget.y;
									rx = ry = 0.5;
									dx = 0;
									dy = 0;
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
		
		if ( hp == 0 && bsup !=null && bsdown != null) {
			if ( ((M.me.timer.ufr>>1) & 1) == 0 )
				bsup.alpha = bsdown.alpha = 0;
			else
				bsup.alpha = bsdown.alpha = 1.0;
		}
		
		if ( hp <= 0 ) return;
		
		var lev = M.me.level;
		var dhy = M.me.level.hero.cy - cy;
		
		
		if ( dhy > 20 || dhy < -10) {
			#if debug el.alpha = 1.0; #end
			return;
		}
		
		#if debug
		el.alpha = 0.5;
		#end
		
		if( nmyType != Boss)
			tickAi();
		else 
			tickBoss();
		
		switch(nmyType) {
			case Boss: rosaceBoss();
			default:rosace8();
		}
		
		
	}
	
	public function rosaceBoss() {
		if ( Math.abs(dx) <= 0.01 ) dx = 0;
		if ( Math.abs(dy) <= 0.01 ) dy = 0;
		
		var ndir : Dir = null;
		var fl = 0;
		
		if ( dy > Char.rosaceLim) 			{ fl |= (1 << 0);}
		else if ( dy < -Char.rosaceLim) 		{ fl |= (1 << 1); }
		
		if ( dx < -Char.rosaceLim) 			{ fl |= (1 << 2);}
		else if ( dx > Char.rosaceLim)		{ fl |= (1 << 3); }
		
		isRunning = true;
	
		if ( fl != 0 ) {
			ndir = switch(fl) {
				case 0 : isRunning = false; null;
				case 1 : S;
				case 2 : S;
				
				case 4: SW;
				case 5: SW;
				case 6: SW;
				
				case 8: SE;
				case 9: SE;
				case 10: SE;
				default:
			}
			
		}
		syncDir(dir,ndir);
	}
	
	var aggroDist=0;
	var bossState(default, set) : BS;
	
	public function set_bossState(v) {
		if( v != bossState){
			bossStateLife = 0;
			if ( bossState == ShootAtWill ) {
				addMessage("ALARM !");
			}
		}
		return bossState = v;
	}
	
	var bossStateLife : Int = 0;
	
	public function tickBoss()
	{
		if ( hp <= 0 ) return;
		
		var char = M.me.level.hero;
		
		var dChar = Math.abs( MathEx.sqrI(cy - char.cy) + MathEx.sqrI(cx - char.cx));
		var dAggro = 20 * 20;
		if ( aggroDist != 0) dAggro = aggroDist*aggroDist;
		var dStop = 10 * 10;
		
		var q = getHeroQuadrant();
		var tickAggro = (dir == q || dir.next(Dir) == q || dir.prev(Dir) == q );
	
		if (hp == 15) {
			currentGun.spread = Math.PI;
			currentGun.maxCooldown *= 4;
			hp = 14;
		}
		
		switch(nmyType) {
			default: 
				switch(state) {
					default:
						state = Idle;
					case Idle:
						if ( stateLife > 20) {
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
						
					case Watch: state = Idle;
					case Run: {
						if ( curTarget == null) {
							state  = Idle;
							lastTargets.clear();
							//trace("getting back to idle");
						}
						else{
							if ( cx == curTarget.x && cy == curTarget.y 
								&& MathEx.isNear(rx, 0.5, 0.1)
								&& MathEx.isNear(ry, 0.5, 0.1)
							) {
								
								if ( getCell().has( WP_WAIT ) && stateLife <= 20) {
									dx = 0.0;
									dy = 0.0;
									return;
								}
								
								//change way point
								var wp = getNearWaypoint();
								if ( getNearWaypoint().length == 0 ) {
									state = Idle;
									curTarget.copy( origin );
									return;
								}
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
								stateLife = 0;
								tickBoss();
							}
							else {
								var realx = curTarget.x * 16 + 8;
								var realy = curTarget.y * 16 + 8;
								var diffX = realx - realX();
								var diffY = realy - realY();
								var lenDiff = Math.sqrt(diffX * diffX + diffY * diffY);
								
								if ( lenDiff <= 1.0 ) 
								{
									cx = curTarget.x;
									cy = curTarget.y;
									rx = ry = 0.5;
									dx = 0;
									dy = 0;
								}
								else 
								{
									var ddx = diffX / lenDiff * sp;
									var ddy = diffY / lenDiff * sp;
									
									dx = ddx;
									dy = ddy;
								}
							}
						}
					}
					
				}
		}
		
		if (bossState == null){
			bossState = Waitplayer;
		}
		
		switch(bossState) {
			case Waitplayer:
				var p = M.me.level.hero;
				if ( MathEx.dist(realX(), realY(), p.realX(), p.realY()) <= 200) {
					bossState = Talk;
				}
			case Talk:
				if (bossStateLife == 10) {
					
					bossStateLife=11;
					if ( M.me.level.bgm != null) M.me.level.bgm.stop();
					if ( bgm == null) bgm = new Chased().play(0, 1000);
					bgm.soundTransform = new flash.media.SoundTransform(0.2);
					addPersistMessage("Grrrr ! So you are that badass that decimate my treasure !\n[SPACE to continue]",
					
					function() {
						if ( Key.isDown(Key.SPACE)) {
							var t = addMessage("I see");
							t.onEnd = function() {
								
								bossState = Choice;
							}
							return true;
						}
						else return false;
					});
				}
			case Choice:
				if (bossStateLife <= 2) {
					bossStateLife = 3;
					var resp = ["\n[Press key 1]-OVER MY DEAD BODY", "\n[Press key 2]-I'll pay !"];
					var msg = "You are now a rich bunny, let's make a deal.\n $500000 and i'll let you go!\n";
					if ( M.me.ui.score <= 500000) {
						msg += "\nYou can't pay...\n";
						msg += resp[0];
					}
					else {
						msg += resp[0];
						msg += resp[1];
					}
					addPersistMessage(msg,
					function() {
						if ( Key.isDown(Key.NUMBER_1)) {
							bossState = ShootAtWill;
							var t = addMessage("Let's Rock then !");
							return true;
						}
						else if ( Key.isDown(Key.NUMBER_2)) {
							
							var t = addMessage("I am rich then !!!");
							M.me.ui.score -= 500000;
							M.me.timer.delay(M.me.endGame, 30);
							return true;
						}
						else return false;
					});
				}
			default:
			if( currentGun!= null)
				if ( currentGun.fire() )
					isShooting = Char.shootCooldown;	
		}
		bossStateLife++;
	}
	
	
	public inline function getBust() {
		return switch(nmyType) {
			case Normal:"opp";
			case Heavy:"heavy";
			case Boss:"boss";
		}
	}
	
	var bgm : SoundChannel;
	
	public override function syncDir(odir:Dir, ndir:Dir) {
		
		if ( state == Hit ) return;
		
		isRunning = !(MathEx.is0( dx ) && MathEx.is0( dy ));
		
		if ( ndir == null) ndir = odir;
		
		
		if ( isShooting >= 0)
			bsup.playAnim('${getBust()}_shoot_' + Std.string(ndir).toLowerCase());
		else {
			bsup.playAnim('${getBust()}_shoot_' + Std.string(ndir).toLowerCase());
			bsup.stopAnim(0);
		}
		
		var verb = isRunning?"run":"idle";
		
		var f = 
		switch(ndir) {
			case N: 'opp_${verb}_n';
			case S: 'opp_${verb}_s';
				
			case E, NE, SE: 'opp_${verb}_e';
			case W, NW, SW: 'opp_${verb}_w'; 
		}
		var a = bsdown.playAnim(f);
		if ( !a) throw "no such anim "+f;
		
		super.syncDir(odir, ndir);
	}
	
	public override function onHurt() {
		super.onHurt();
		dir = getHeroQuadrant();
		
		if( nmyType!=Boss ){
			addToMajorDir(dir, -0.5);
		}
		else {
			if ( bossState == Choice || bossState == Talk) {
				M.me.ui.tfMsg.clear();
			}
			bossState = ShootAtWill;
		}
			
		addScore( 25 );
		state = Hit;
		bsup.playAnim( '${getBust()}_hit', 1);
	}
	
	public override function onKill() {
		super.onKill();
		addScore( 50 );
		bsup.playAnim( '${getBust()}_dead', 1);
		
		if ( nmyType == Boss) {
			M.me.canPlay = false;
			M.me.timer.delay( M.me.endGame, 120);
			M.me.level.hero.addMessage("VICTORYYYYY");
			M.me.level.hero.bsup.playAnim("redhead_victory");
			
			var spr = M.me.data.lib.getAndPlay("game_over");
				spr.x = 120;
			spr.y = 200;
			M.me.ui.addChild( spr );
		}
	}
}