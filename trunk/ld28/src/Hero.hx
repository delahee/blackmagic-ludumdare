import mt.deepnight.Key;

import volute.*;
import Dir;
import Entity;
using volute.Ex;

class Hero extends Char{

	var guns : Array<Gun>;
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
	}
	
	public function down(k) {
		return Key.isDown( k );
	}
	
	public var cd = 0;
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
				
				case 4: E;
				case 5: SW;
				case 6: NW;
				
				case 8: W;
				case 9: SE;
				case 10: NE;
				
				default: 
			}
			
		}

		dx = MathEx.clamp( dx, -mdx, mdx);
		dy = MathEx.clamp( dy, -mdy, mdy);
		
		cd--;
		if ( down( Key.CTRL ) && cd<=0)
			currentGun.fire();
		
		syncDir(dir,ndir);
	}

	public override function syncDir(odir,ndir) {
		if ( ndir == null ) return;
		if ( odir == ndir ) return;
		
		switch(ndir) {
		default:	
		}
		
		var file = "explosion";
		var a =
		switch(ndir) {
			case N, NE, NW: bsdown.playAnim("redhead_run_n");
			case S, SE, SW: bsdown.playAnim("redhead_run_s");
				
			case E: bsdown.playAnim("redhead_run_e");
			case W: bsdown.playAnim("explosion");
		}
		if ( !a) throw "no such anim";
		trace("hero sync dir" + ndir);
		super.syncDir(odir, ndir);
	}
	
}