package ;
import flash.display.Bitmap;
import flash.filters.GlowFilter;
import flash.ui.Keyboard;
import haxe.Public;
import haxe.xml.Fast;
import starling.display.Image;
import starling.display.QuadBatch;
import volute.algo.Pool;
import volute.fx.FX;
import volute.Lib;
import volute.t.Vec2;
import volute.Dice;

using volute.Ex;
import mt.deepnight.Key;

import Data;

class ScreenLevel extends Screen {
	var player : Player;
	var asters : List<ScriptedAster>;
	
	static var me : ScreenLevel;
	public var spawnQueue : List<{d:Float,a : ScriptedAster}>;
	
	public var sf0 : Starfield;
	public var sf1 : Starfield;
	public var bg0 : Image;
	
	public function new() {
		super();
		me = this;
		spawnQueue = new List();
		
		var bmd = new BmpDegrade(0, 0, false);
		bg0 = Image.fromBitmap( new Bitmap(bmd));
		bmd.dispose();
		
		bg0.blendMode = starling.display.BlendMode.NORMAL;
		bg0.alpha = 0.3;
	}
	
	
	public override function init(){
		super.init();
		
		new BGM().play(0,1000);
		
		asters = new List<ScriptedAster>();
		var bmp = Data.me.level;
		var w = bmp.width; var h = bmp.height;
		var asterHash = new IntHash();
		for ( s in Data.me.ld.nodes.aster ) {
			asterHash.set( Std.parseInt( s.att.colorId ), s );
		}
		
		sf0 = new Starfield( M.me,w * 8, Lib.h(), 0.5);
		sf0.root.alpha = 0.8;
		
		M.me.addChild( bg0);
		sf1 = new Starfield( M.me, w * 4, Lib.h(), 0.85);
		
		for (y in 0...h) {
			for(x in 0...w){
			var px = bmp.getPixel( x, y );
			
			if ( px > 0 ){
			var xml = asterHash.get( px );
			if ( xml == null) xml = asterHash.get( 0 );
			
			var a : ScriptedAster = new ScriptedAster( xml, new Vec2(x,y)); 
			a.mc = new Aster( a.isFire(), a.getSize(), a );
			
			if ( a.getBaseDelay() <= 0)
				asters.push(spawn(a));
			else 
				spawnQueue.push( { d: a.getBaseDelay(), a:a } );
			
			level.addAster( a.mc );
			
			if ( xml.has.cine ) {
				var c = Data.me.cines.get( xml.att.cine );
				a.mc.cine = c;
			}
		}}}
		
		player = new Player();
		
		for ( a in asters )
			if ( a.isSpawn() ) {
				player.setAsterAngle( a.mc, - Math.PI / 2 );
				addChild( player.mc);
				break;
			}
			
		bg.toBack();
		sf0.root.toFront();
		bg0.toFront();
		sf1.root.toFront();
		
		M.view.toFront();
		
		for ( a in level.asters)
			a.img.toFront();
		
		setChildIndex( player.mc , numChildren );
	}
	
	public override function kill() {
		var b = super.kill();
		if (b)
		{
			for ( a in asters) removeChild( a.mc.img );
			sf0.dispose();
			sf1.dispose();
			bg0.dispose();
		}
		return b;
	}
	
	public override function update() {
		var tr = M.me.transition;
		if ( tr != null) {
			tr.alpha -= 0.01; 
			if ( tr.alpha <= 0.001 && tr.parent != null)
			{
				tr.parent.removeChild( tr );
				M.me.transition = null;
			}
		}
		
		var fr = M.timer.df;
		super.update();
		
		if( player.input )
		{
			onPlayFrame();
			
			#if debug
			if ( Key.isDown( Keyboard.CONTROL ) && Key.isDown( Keyboard.LEFT ))
				M.view.x += 5 * fr;
			if ( Key.isDown( Keyboard.CONTROL ) && Key.isDown( Keyboard.RIGHT ))
				M.view.x -= 5 * fr;
				
			if ( Key.isDown( Keyboard.CONTROL ) && Key.isDown( Keyboard.UP ))
				M.view.y += 5 * fr;
			if ( Key.isDown( Keyboard.CONTROL ) && Key.isDown( Keyboard.DOWN ))
				M.view.y -= 5 * fr;
			#end
		}
		
		tick(fr);
			
		if ( spawnQueue.length > 0)
			spawnQueue = spawnQueue.filter( function(e)
			{
				e.d -= fr;
				if ( e.d <= 0 ) {
					spawn( e.a,true);
				}
				return e.d<=0;
			});
			
		sf0.root.x = - Player.me.pos.x * 0.01;
		sf0.update();
		
		sf1.root.x = - Player.me.pos.x * 0.025;
		sf1.update();
		
		#if debug
		if ( Key.isToggled(Keyboard.A) ) {
			for ( f in asters )
				if ( f.mc.cine != null && f.mc.cine.type == ELVIS ) {
					player.setAsterAngle( f.mc, 0);
					player.update();
				}
		}
		#end
		
	}
	
	public function tick(fr) {
		player.update();
		for ( a in asters ) {
			exec( a , fr);
		}
	}
	
	public function murder(sa:ScriptedAster)
	{
		if ( sa.mc == Player.me.aster )
			Player.me.onFly();
		
		sa.dead = true;
		sa.mc.move( 1000000, 1000000);
		if ( sa.getBaseDelay() > 0 ) sa.delay = sa.getBaseDelay();
			
	}
	
	public function exec(sa : ScriptedAster, fr: Float) {
		if ( sa.dead ){
			if ( sa.isRespawn()){
				if( sa.delay <= 0){
					sa.time = 0;
					sa.dead = false;
					spawn( sa ,true );
				}
				sa.delay -= fr;
			}
			else
			{
				sa.mc.dispose();
				asters.remove( sa);
			}
		}
		else
		{
			if ( sa.mc.y <- 200|| sa.mc.y > Lib.h() + 200) 
				murder(sa);
			else if ( sa.haveLife() && sa.getLife() < sa.time ) 
				murder(sa);
			else 
			{
				if (sa.haveLife()) {
					var l = 30;
					if ( (sa.getLife() - sa.time) <= l ) {
						var r = (sa.getLife() - sa.time) / l;//1-0
						var t = r;
						t = Math.sqrt(t);
						
						t *= 1.1;
						
						sa.mc.img.scaleX = sa.mc.img.scaleY = t;
						sa.mc.sz = sa.mc.osz * t;
					}
				}
					
				if ( sa.mc.scripted){
					sa.mc.a += sa.getRotSpeed() * fr;
					if ( sa.speed > 0) sa.mc.translate(sa.dir.x * sa.speed * fr, sa.dir.y * sa.speed * fr);
					sa.time += fr;
				}
			}
		}
		
		if ( Math.abs( sa.speed ) >= 0.01 )
		{
			var res = null;
			var pos = sa.mc.getCenter();
			var amc = sa.mc;
			
			function proc(e:Entity) {
				if ( volute.Coll.testCircleCircle( pos.x, pos.y, 50, e.x, e.y, e.sz ) && e!=amc) {
					res = e;
					return true;
				}
				return false;
			}
			
			var resAct = cast res;
			var ast = sa.mc;
			level.grid.iterRange( Std.int(ast.x), Std.int(ast.y), Std.int(ast.sz * 0.5), proc);
		}
		
		sa.mc.update();
	}
	
	public function spawn( sa : ScriptedAster,late = false) {
		
		sa.mc.move( sa.coo.x * 32.0, sa.coo.y * 32.0 );
		
		if ( late){
			sa.mc.img.scaleX = sa.mc.img.scaleY = 0;
			
			var f = new FX(1.0);
			f.onUpdate = function(t) {
				t = Math.sqrt(t);
				if ( t >= 1.0) t = 1.0;
				sa.mc.img.scaleX = sa.mc.img.scaleY = t;
				sa.mc.sz = sa.mc.osz * t;
			}
		}
		
		if ( sa.mc.img.parent == null)
			addChild( sa.mc.img );
		
		return sa;
	}
	
	var timer = 0.0;
	public function onPlayFrame() {
		var fr = M.timer.df;
		if ( timer <= 0) {
			tryLaunchPhrase();
			timer = 60;
		}
		timer -= fr;
	}
	
	var introLevel = 0;
	function tryLaunchPhrase() {
		if ( Dice.percent( 50 )) {
			var t = Data.me.rdText[introLevel++];
			introLevel = introLevel % 3;
			if (t != null) 
				player.say(t);
		}
	}
}






