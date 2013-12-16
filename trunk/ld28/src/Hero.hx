import mt.deepnight.Key;
import mt.deepnight.Tweenie.TType;
import mt.deepnight.Tweenie;
import volute.t.Vec2i;
import Nmy;
import Types;

import volute.*;
import Dir;
import Entity;
using volute.Ex;

class Hero extends Char{

	var guns : Array<Gun>;
	var hasChest = false;
	var chestTakeCd = 0;
	public function new() {
		name = "redhead";
		
		dir = N;
		
		super();
		
		type = ET_PLAYER;
		guns = [];
		
		var g = null;
		
		//basic gun
		guns[0] = g = new Gun(this);
		g.maxBullets = 12;
		g.maxCooldown = 16;
		g.init();
		
		//gatling
		guns[1] = g = new Gun(this);
		g.maxBullets = 80;
		g.maxCooldown = 1;
		g.init();
		
		//rocket
		guns[2] = g = new Gun(this);
		g.maxBullets = 2;
		g.maxCooldown = 5;
		g.init();
		
		//rocket
		guns[3] = g = new Gun(this);
		g.maxBullets = 40;
		g.maxCooldown = 12;
		g.init();
		
		currentGun = guns[0];
		
		hp = 1000000;
		
	//	bsup.y += 2;
	//	bsup.x -= 1;
	}
	
	
	public inline function getChest() {
		return M.me.level.chest;
	}
	
	public override function customTest(cx, cy) {
		var c = getChest();
		return (c.cy == cy ||c.cy-1==cy) && (c.cx == cx||c.cx + 1 == cx);
	}
	
	public override function onHurt() {
		super.onHurt();
		if( hasChest )
			addScore( -5000);
		else 
			addScore( -500);
		
	}
	
	public override function getFireOfset() :Vec2i{
		return 
		switch(dir) {
			case N:new Vec2i(3, -1);
			case S:new Vec2i(-3, -1);
			default: super.getFireOfset();
		}
	}
	
	public function down(k) {
		return Key.isDown( k );
	}
	
	public function input() {
		var mdx = 0.15;
		var mdy = 0.15;
		var k = 0.05;
		
		if ( hasChest ) { 
			k *= 0.5;
			mdx *= 0.5;
			mdy *= 0.5;
		}
			
		
		var c = getChest();
		var fl = 0;
		
		var ndir : Dir= null;
		/*
		#if debug
		if ( down( Key.ENTER ))	{
			for ( e in M.me.level.store) {
				if ( e.type == ET_OPP && (cast e).nmyType == NmyType.Boss) {
					e.hp = 0;
					e.onKill();
					return;
				}
			}
		}
		#end
		*/
		
		if ( down( Key.DOWN )) 			{ dy += k; fl |= (1 << 0);}
		else if ( down( Key.UP )) 		{ dy -= k; fl |= (1 << 1); }
		
		if ( down( Key.LEFT )) 			{ dx -= k; fl |= (1 << 2);}
		else if ( down( Key.RIGHT ))	{ dx += k; fl |= (1 << 3); }
		
		if ( fl != 0 ) {
			ndir=
			switch(fl) {
				
				case 1 : S;
				case 2 : N;
				
				case 4: W;
				case 5: SW;
				case 6: NW;
				
				case 8: E;
				case 9: SE;
				case 10: NE;
				
				default: 
			}
			
		}

		var wasRunning = MathEx.is0( dx ) && MathEx.is0( dy );
		
		dx = MathEx.clamp( dx, -mdx, mdx);
		dy = MathEx.clamp( dy, -mdy, mdy);
		
		if ( Math.abs(dx) <= 0.01 ) dx = 0;
		if ( Math.abs(dy) <= 0.01 ) dy = 0;
		
		isRunning = !(MathEx.is0( dx ) && MathEx.is0( dy ));
		
		var wasShooting  = isShooting;
		
		chestTakeCd--;
		if ( down( Key.CTRL ) ) {
			
			if ( chestTakeCd <= 0 && !hasChest && MathEx.dist(realX(),realY(),c.realX(),c.realY() )<= 32 ){
				hasChest = true;
				level().remove(c);
				c.cx = 0;
				c.cy = 0;
				c.rx = 0;
				c.ry = 0;
				c.syncPos();
				bsdown.addChild( c.el );
				c.el.x -= 16;
				c.el.y -= 16;
				chestTakeCd = 4;
				hasChest = true;
				addMessage(["come back baby","mummy gotcha","precioooouuus","missed you too","yess"].random());
			}
			else {
				if (chestTakeCd <= 0 && hasChest) {
					c.detach();
					level().add(c);
					
					if ( !test( cx-1, cy - 2)) {
						c.cx = cx-1;
						c.cy = cy-2;
						c.rx = rx;
						c.ry = ry;
						c.syncPos();
					}
					else if ( !test( cx-1, cy + 2)) {
						c.cx = cx-1;
						c.cy = cy+2;
						c.rx = rx;
						c.ry = ry;
						c.syncPos();
					}
					else if ( !test( cx+1, cy)) {
						c.cx = cx+1;
						c.cy = cy;
						c.rx = rx;
						c.ry = ry;
						c.syncPos();
					}
					else {
						c.cx = 10;
						c.cy = cy;
						c.rx = rx;
						c.ry = ry;
						c.syncPos();
					}
					
					hasChest = false;
					chestTakeCd = 4;
					M.me.tweenie.create(c, "ry", c.ry + 1 / 16.0, TType.TZigZag, 100 );
					addMessage(["wait a sec","time to kick ass !","again!"].random());
				}
				else if ( currentGun.fire() ) 
					isShooting = Char.shootCooldown;
			}
		}
			
		syncDir(dir,ndir);
	}

	public override function syncDir(odir, ndir) {
		if ( ndir == null) ndir = odir;
		
		if ( isShooting >= 0){
			bsup.playAnim("redhead_shoot_" + Std.string(ndir).toLowerCase());
		}
		else {
			bsup.playAnim("redhead_shoot_" + Std.string(ndir).toLowerCase());
			bsup.stopAnim(0);
		}
		
		var verb = isRunning?"run":"idle";
		
		var f = 
		switch(ndir) {
			case N: 'redhead_${verb}_n';
			case S: 'redhead_${verb}_s';
				
			case E, NE, SE: 'redhead_${verb}_e';
			case W, NW, SW: 'redhead_${verb}_w'; 
		}
		var a = bsdown.playAnim(f);
		if ( !a) throw "no such anim "+f;
		
		super.syncDir(odir, ndir);
	}
	
}