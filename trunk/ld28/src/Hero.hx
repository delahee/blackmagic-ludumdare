import mt.deepnight.Key;

import volute.*;
import Entity;
using volute.Ex;

class Hero extends Char{

	public function new() {
		super();
		name = "redhead";
		type = ET_PLAYER;
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
		
		if ( down( Key.DOWN )) 			{ dy += k; fl |= (1 << 0);}
		else if ( down( Key.UP )) 		{ dy -= k; fl |= (1 << 1); }
		
		if ( down( Key.LEFT )) 			{ dx -= k; fl |= (1 << 2);}
		else if ( down( Key.RIGHT ))	{ dx += k; fl |= (1 << 3); }
		
		if ( fl != 0 ) {
			dir=
			switch(fl) {
				case 0: N;
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
		if ( down( Key.CTRL ) && cd<=0) {
			var bl = new Bullet();
			
			bl.harm |= 1 << ET_OPP.index();
			
			bl.x = el.x + bl.spr.width * 0.5;
			bl.y = el.y + bl.spr.height * 0.5;
			
			l.addBullet( bl );
			
			var sp = 12.0;
			
			var spi4 = Math.sin(-Math.PI * 0.25);
			var cpi4 = Math.cos( -Math.PI * 0.25);
			
			var r2d2 = 1.414 * 0.5;
			switch(dir) {
				
				case N: bl.dy = -sp;
				case S: bl.dy = sp;
					
				case E: bl.dx = -sp;
				case W: bl.dx = sp;
					
				default:
				
				case NW: bl.dx = -sp*r2d2;  bl.dy = -sp*r2d2;
				case SW: bl.dx = -sp*r2d2; 	bl.dy = sp*r2d2;
					     
				case NE: bl.dx = sp*r2d2; 	bl.dy = -sp*r2d2;
				case SE: bl.dx = sp*r2d2; 	bl.dy = sp*r2d2;
				
			}
			
			bl.x += dx;
			bl.y += dy;
			
			//trace('bl ' + bl.x + " " + bl.y);
			cd = 4;
		}
		
		syncDir();
	}
	
	
}