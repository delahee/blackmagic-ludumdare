import mt.gx.Dice;

@:publicFields
class Zombie extends mt.deepnight.slb.HSpriteBE {
	var d(get, null) : D; function get_d() return App.me.d;
	var g(get, null) : G; function get_g() return App.me.g;
	var c(get, null) : Car; function get_c() return Car.me;
	
	public var hp = 10;
	public var rx = 0.0;
	public var ry = 0.0;
	
	public var dx = 0.0;
	public var dy = 0.0;
	
	public var onCar : Bool;
	
	public function new(a,lib,c,?f=0) {
		super(a, lib, c, f);
		setCenterRatio(0.5, 1.0);
	}
	
	public function update(dt) {
		if ( !onCar) {
			rx += dx;
			ry += dy;
			
			x = Math.round( rx );
			y = Math.round( ry );
			
			if ( !onCar && isOnCar() ) {
				onCar = true;
				ofsCarX = x - c.cacheBounds.x;
				ofsCarY = y - c.cacheBounds.y;
			}
			
		}
		else {
			dx = 0;
			dy = 0;
		
			rx = x = c.cacheBounds.x + ofsCarX;
			ry = y = c.cacheBounds.y + ofsCarY;
		}
	}
	
	var ofsCarX = 0.;
	var ofsCarY = 0.;
	var ofsHookX = 0.;
	
	public inline function isOnCar() {
		return x >= c.cacheBounds.x + ofsHookX;
	}
}

class Zombies {
	var d(get, null) : D; inline function get_d() return App.me.d;
	var g(get, null) : G; inline function get_g() return App.me.g;
	var c(get, null) : Car; inline function get_c() return Car.me;
	
	public var sb : h2d.SpriteBatch;
	var rand : mt.Rand;
	var elapsedTime = 0.0;
	var level : Int = 0;
	
	var zombies : List<Zombie> = new List();
	
	public function new(p)  {
		sb =  new h2d.SpriteBatch(d.char.tile, p);
		rand = new mt.Rand(0);
		setLevel(0);
	}
	
	public function setLevel(level:Int) {
		var seed = 
		switch( level ) {
			default: throw "acer";
			case 0: 0;
			case 1: 0x17deadf0;
			case 2: 0x3ded3ded;
			case 3: 0x3ded0015;
		};
		rand.initSeed( seed );
		this.level = level;
		
		sb.removeAllElements();
		zombies = new List();
		elapsedTime = 0.0;
	}
	
	public function update(dTime:Float) {
		if ( level == 0) {
			elapsedTime = 0;
			return;
		}
			
		for ( z in zombies) {
			z.update(dTime);
		}
		
		var start = Std.int( elapsedTime ) * 20;
		var end = Std.int( elapsedTime + dTime ) * 20;
		for ( n in start...end ) {
			switch(level) {
				case 1:
					if ( mt.gx.Dice.percent(rand,5)) {
						spawnZombie();
					}
			}
		}
		
		elapsedTime += dTime;
	}
	
	public function spawnZombie() {
		var z = new Zombie(sb, d.char, "zombie00");
		
		
		z.ry = Dice.rollF( c.by + 20, c.by + c.cacheBounds.height - 10) + z.height * 0.8;
		z.rx = -30 + Dice.rollF( 0, 25);
		
		z.x = z.rx;
		z.y = z.ry;
		
		z.changePriority( -Math.round(z.y) );
		
		z.dx = 2 + Dice.rollF( 0, 0.5);
		z.scale( Dice.rollF(0.95, 1.0) );
		z.ofsHookX = Dice.rollF( 0.0, 8.0 );
		
		zombies.add(z);
	}
	
}