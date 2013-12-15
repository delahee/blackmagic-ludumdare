import Entity;
using volute.Ex;

import volute.MathEx;
import volute.Dice;
enum BulletType{
	Standard;
	Fire;
	rocket;
}

class Gun
{
	var c:Char;
	
	var curCooldown : Int;
	public var maxCooldown : Int;
	
	var bullets : Int;
	public var maxBullets : Int;
	
	var reloading : Bool = false;
	var bulletType : BulletType;
	var recoil = 0.05;
	
	public function new( e : Char ) 
	{
		this.c = e;
		bulletType = Standard;
	}
	
	public function init() {
		bullets = maxBullets;
		curCooldown = 0;
	}
	
	public function update() {
		curCooldown--;
		if (curCooldown == 0 && reloading){
			bullets = maxBullets;
			reloading = false;
		}
	}
	
	public function fire() {
		
		if ( curCooldown > 0)
			return false;
			
		var dir = c.dir;
		var bl = new Bullet();
			
		if( c.type == ET_PLAYER)
			bl.harm |= 1 << ET_OPP.index();
		else 
			bl.harm |= 1 << ET_PLAYER.index();
		
		var f = c.getFireOfset();
		bl.x = c.el.x + f.x + bl.spr.width * 0.5;
		bl.y = c.el.y + f.y - c.el.height * 0.5 + bl.spr.height * 0.5;
		
		M.me.level.addBullet( bl );
		
		var sp = 12.0;
		
		var spi4 = Math.sin(-Math.PI * 0.25);
		var cpi4 = Math.cos( -Math.PI * 0.25);
		
		var r2d2 = 1.414 * 0.5;
		switch(dir) {
			
			case N: bl.dy = -sp;
			case S: bl.dy = sp;
				
			case E: bl.dx = sp;
			case W: bl.dx = -sp;
				
			default:
			
			case NW: bl.dx = -sp*r2d2;  bl.dy = -sp*r2d2;
			case SW: bl.dx = -sp*r2d2; 	bl.dy = sp*r2d2;
					 
			case NE: bl.dx = sp*r2d2; 	bl.dy = -sp*r2d2;
			case SE: bl.dx = sp*r2d2; 	bl.dy = sp*r2d2;
			
		}
		
		curCooldown = maxCooldown;
		bullets--;
		if ( bullets == 0 ){
			curCooldown *= 5;
			reloading = true;
			c.addMessage("reloading !");
		}
		
		c.addToMajorDir( c.dir, -Dice.rollF( recoil, 2 * recoil) );
		
		return true;
	}
}