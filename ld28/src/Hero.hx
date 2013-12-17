import flash.geom.ColorTransform;
import flash.Lib;
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
		g.bulletLife = 10;
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
		#if debug 
		currentGun = guns[1];
		#end
		hp = 1000000;
		
	//	bsup.y += 2;
	//	bsup.x -= 1;
	}
	
	
	public inline function getChest() {
		return M.me.level.chest;
	}
	
	//public override function customTest(cx, cy) {
	//	var c = getChest();
	//	return (c.cy == cy ||c.cy-1==cy) && (c.cx == cx||c.cx + 1 == cx);
	//}
	
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
	
	var stepCd = 0;
	public function input() {
		var mdx = 0.14;
		var mdy = 0.14;
		var k = 0.035;
		
		#if false 
		mdx *= 10;
		mdy *= 10;
		//var k = 0.035;
		k *= 10;
		#end
		
		if ( hasChest ) { 
			k *= 0.5;
			mdx *= 0.5;
			mdy *= 0.5;
		}
			
		
		var c = getChest();
		var fl = 0;
		
		var ndir : Dir = null;
		
		
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
		
		
		if ( down( Key.DOWN )) 			{ dy += k; fl |= (1 << 0);}
		else if ( down( Key.UP )) 		{ dy -= k; fl |= (1 << 1); }
		
		if ( down( Key.LEFT )) 			{ dx -= k; fl |= (1 << 2);}
		else if ( down( Key.RIGHT ))	{ dx += k; fl |= (1 << 3); }
		
		ndir = null;
		var stg = flash.Lib.current.stage;
		var mx = stg.mouseX * 0.5;
		var my = stg.mouseY * 0.5;
		var glbX = realX() - M.me.level.view.x;
		var glbY = realY() - M.me.level.view.y;
			
		var a = Math.atan2( mx - glbX, my - glbY );
		var d = - Math.PI/2  + a;
		dir = angleToDir(d);
			
		if ( fl != 0 ) {
			
			var ui = M.me.ui;
			if ( !ui.fading) {
				for ( s in ui.getTitle()) {
					if ( s == null) {
						var i = 0;
					}
					var ct = new ColorTransform();
					ct.redMultiplier = ct.greenMultiplier = ct.blueMultiplier = 0;
					ct.redOffset = ct.greenOffset = ct.blueOffset = 255;
					s.transform.colorTransform = ct;
					
					M.me.tweenie.create(s, "alpha", 0, TType.TBurnOut, 350);
				}
				ui.fading = true;
			}
			
			stepCd--;
			
			if ( stepCd  <= 0 ) {
				new Types.Sand().play();
				stepCd = 3;
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
		
		var fire = down( Key.CTRL );
		var lvl = level();
		if ( lvl.mouseDown != null) {
			fire = true;
		}
		
		if ( fire ) {
			
			if ( chestTakeCd <= 0 && !hasChest && MathEx.dist(realX(),realY(),c.realX(),c.realY() )<= 24 ){
				hasChest = true;
				level().remove(c);
				c.cx = 0;
				c.cy = 0;
				c.rx = 0.5;
				c.ry = 0.5;
				c.syncPos();
				bsdown.addChild( c.el );
				chestTakeCd = 4;
				hasChest = true;
				addMessage(["come back baby","mummy gotcha","precioooouuus","missed you too","yess"].random());
			}
			else {
				if (chestTakeCd <= 0 && hasChest) {
					c.detach();
					level().add(c);
					
					if ( !test( cx, cy - 2)) {
						c.cx = cx;
						c.cy = cy-2;
						c.rx = rx;
						c.ry = ry;
						c.syncPos();
					}
					else if ( !test( cx, cy + 2)) {
						c.cx = cx;
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
		
		if (hasChest) {
			c.el.y = ((Std.int(el.y) >> 1) & 1) - 8;
			c.el.x = 0;// c.el.width * 0.5;
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