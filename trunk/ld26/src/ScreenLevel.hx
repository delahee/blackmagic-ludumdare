package ;
import flash.ui.Keyboard;
import haxe.Public;
import haxe.xml.Fast;
import volute.Lib;
import volute.t.Vec2;

import mt.deepnight.Key;

class ScreenLevel extends Screen {
	
	var asters : List<ScriptedAster>;
	var player : Player;
	static var me : ScreenLevel;
	
	public function new() {
		super();
		me = this;
	}
	
	public override function init(){
		super.init();
		asters = new List<ScriptedAster>();
		
		var bmp = Data.me.level;
		var w = bmp.width; var h = bmp.height;
		var asterHash = new IntHash();
		for ( s in Data.me.ld.nodes.aster ) {
			asterHash.set( Std.parseInt( s.att.colorId ), s );
		}
		
		for (y in 0...h) {
			for(x in 0...w){
			var px = bmp.getPixel( x, y );
			
			if ( px > 0 ){
			var xml = asterHash.get( px );
			if ( xml == null) xml = asterHash.get( 0 );
			
			var a : ScriptedAster = new ScriptedAster( xml, new Vec2(x,y)); 
			a.mc = new Aster( a.isFire(), a.getSize() );
			a.mc.script = a;
			asters.push(spawn(a));
		}}}
		
		player = new Player();
		
		for ( a in asters )
			if ( a.isSpawn() ) {
				player.setAsterAngle( a.mc, 0 );
				break;
			}
		
	
	}
	
	public override function kill() {
		var b = super.kill();
		for ( a in asters)
			removeChild( a.mc.img );
		asters = new List<ScriptedAster>();
		return b;
	}
	
	public override function update(){
		super.update();
		
		var fr = M.timer.df;
		tick(fr);
		
		if ( Key.isDown( Keyboard.LEFT ))
			M.view.x += 5 * fr;
		
		if ( Key.isDown( Keyboard.RIGHT ))
			M.view.x -= 5 * fr;
	}
	
	public function tick(fr){
		for ( a in asters ) {
			exec( a , fr);
		}
	}
	
	public function exec(sa : ScriptedAster, fr: Float) {
		
		
		if ( sa.dead ){
			if ( sa.isRespawn())
			{
				sa.time = 0;
				sa.dead = false;
				spawn( sa );
			}
			else
			{
				sa.mc.dispose();
				asters.remove( sa);
			}
		}
		else
		{
			if ( sa.mc.y < 200|| sa.mc.y > Lib.h() + 200) 
				sa.dead = true;
			else if ( sa.haveLife() && sa.getLife() < sa.time ) 
				sa.dead = true;
			else 
			{
				if ( !sa.mc.scripted){
					sa.mc.a += sa.getRotSpeed() * fr;
					if ( sa.speed > 0) sa.mc.translate(sa.dir.x * sa.speed * fr, sa.dir.y * sa.speed * fr);
					sa.time += fr;
				}
			}
		}
		
		var astera = Lambda.array( asters );
		
		for ( i in 0...astera.length)
			for ( j in i...astera.length)
			{
				var x = astera[i];
				var y = astera[j];
				
				var cx = x.mc.getCenter();
				var cy = y.mc.getCenter();
				
				if ( x.mc.intersects( y.mc )) {
					
					//if ( x.isFire() && y.isFire())
					//	throw "assert";
						
					if ( x.isFire() && !y.isFire()) {
						y.mc.onBurn();
					}
					
					if ( !x.isFire() && x.isFire()) {
						x.mc.onBurn();
					}
					
					x.mc.scripted = false;
					y.mc.scripted = false;
				}
			}
	
		astera = null;
	}
	
	
	
	public function spawn( sa : ScriptedAster){
		sa.mc.move( sa.coo.x * 32.0, sa.coo.y * 32.0 );
		
		if ( sa.mc.img.parent == null)
			addChild( sa.mc.img );
		
		return sa;
	}
	
	
	
}