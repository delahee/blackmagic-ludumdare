import haxe.xml.Fast;
import volute.t.Vec2;

class ScriptedAster implements haxe.Public{ 
	public var xml:Fast;
	public var mc:Aster;
	public var coo: Vec2;
	public var dir: Vec2;
	public var time:Float;
	public var dead = false;
	public var speed = 0.0;
	public var delay:Float=.0;
	
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
	
	function isSpawn()		return xml.has.spawn && (xml.att.spawn == "true" )
	function isCheckpoint() return xml.has.checkpoint && (xml.att.checkpoint == "true" )
	
	function getRotSpeed() 	return !xml.has.rotSpeed ? .0 : Std.parseFloat(xml.att.rotSpeed)
	function getBaseDelay()	return !xml.has.delay ? .0 : Std.parseFloat(xml.att.delay)
}
