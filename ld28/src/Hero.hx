import mt.deepnight.Key;
import volute.t.Vec2i;

import volute.*;
import Dir;
import Entity;
using volute.Ex;

class Hero extends Char{

	var guns : Array<Gun>;
	var hasChest = false;
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
	
	public override function onHurt() {
		super.onHurt();
		if( hasChest )
			addScore( -1000);
		else 
			addScore( -200);
		
		
	}
	
	public override function getFireOfset() :Vec2i{
		return 
		switch(dir) {
			case N:new Vec2i(3, 0);
			case S:new Vec2i(-3, 0);
			default: super.getFireOfset();
		}
	}
	
	public function down(k) {
		return Key.isDown( k );
	}
	
	public function input() {
		var mdx = 0.2;
		var mdy = 0.2;
		var k = 0.05;
		
		var fl = 0;
		
		var ndir : Dir= null;
		
		if ( down( Key.SPACE ))			addMessage("take that");
		
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
		
		if ( down( Key.CTRL ) ){
			if ( currentGun.fire() ) 
				isShooting = Char.shootCooldown;
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
			case N, NE, NW: 'redhead_${verb}_n';
			case S, SE, SW: 'redhead_${verb}_s';
				
			case E: 'redhead_${verb}_e';
			case W: 'redhead_${verb}_w'; 
		}
		var a = bsdown.playAnim(f);
		if ( !a) throw "no such anim "+f;
		
		super.syncDir(odir, ndir);
	}
	
}