package ;
import haxe.Public;
import haxe.xml.Fast;
import volute.Lib;
import volute.t.Vec2;


class ScriptedAster implements Public{ 
	public var xml:Fast;
	public var mc:Aster;
	public var coo: Vec2;
	public var dir: Vec2;
	public var time:Float;
	public var dead = false;
	public var speed = 0.0;
	
	function new(src,coo : Vec2) { 
		xml = src; 
		time = 0; 
		this.coo = coo.clone();
		
		var rcoox = coo.x * 32;
		var rcooy = coo.y * 32;
		
		var a = !xml.has.tgt ? [] : xml.att.tgt.split(',');
		if( a.length > 0){
			var rtgtx = Std.parseFloat(a[0])*32;
			var rtgty = Std.parseFloat(a[1])*32;
			dir = new Vec2( rtgtx - rcoox, rtgty - rcooy);
			dir.safeNormalize(Vec2.ZERO); 
		}
		else 
			dir = Vec2.ZERO.clone();
		
		speed = !xml.has.speed ? 0.0 : Std.parseFloat(xml.att.speed);
	}
	
	function isRespawn() 	return xml.has.respawn && xml.att.respawn == 'true'
	function isFire() 		return xml.has.fire && xml.att.fire == "true" 
	function getSize() 		return xml.has.size ? Std.parseInt(xml.att.size): 32
	function haveLife()		return xml.has.life
	function getLife()		return Std.parseInt(xml.att.life)
	function getRotSpeed() 	return !xml.has.rotSpeed ? .0 : Std.parseFloat(xml.att.rotSpeed)
	
}

class ScreenTestLevel extends Screen {
	
	var asters : List<ScriptedAster>;
	
	public function new() {
		super();
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
			asters.push(spawn(a));
		}}}
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
		
		var fr = M.me.timer.df;
		tick(fr);
	}
	
	public function tick(fr){
		for ( a in asters ) {
			exec( a , fr);
		}
	}
	
	public function exec(sa : ScriptedAster, fr: Float) {
		if ( sa.dead )
		{
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
				sa.mc.a += sa.getRotSpeed() * fr;
				if ( sa.speed > 0) sa.mc.translate(sa.dir.x * sa.speed * fr, sa.dir.y * sa.speed * fr);
				sa.time++;
			}
		}
	}
	
	public function spawn( sa : ScriptedAster){
		sa.mc.move( sa.coo.x * 32.0, sa.coo.y * 32.0 );
		
		if ( sa.mc.img.parent == null)
			addChild( sa.mc.img );
		
		return sa;
	}
	
	
	
}