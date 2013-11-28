import volute.Types;
using volute.com.Ex;
import M;

enum State
{
	STAND;
	WALK;
	JUMP;
	FALL;
	ATTACK;
	AIR_ATTACK;
}

class Char extends Entity
{
	var spr : ElementEx;
	var hasJumped = false;
	var state : State;
	var stateLife : Int;
	
	var hasAirAttacked = false;
	var pause = false;
	var score = 0;
	var timer = 0.0;
	var prevT :Null<Float> = null;
	var souls = 0;
	public function new() 
	{
		super();
		type = ET_PLAYER;
		el = (spr = new ElementEx());
		
		gravity = true;
		state = null;
		
		changeState(STAND);
	}
	
	public function endRatio()
	{
		return  timer / (1000.0*111.0);
	}
	
	public function changeState(s)
	{
		if (s == state)
			return;
			
		switch(s)
		{
			case STAND: M.data.mkChar( spr, "hero", "stand");
			case WALK: 	M.data.mkChar( spr, "hero", "walk");
			case JUMP: 	M.data.mkChar( spr, "hero", "jump");
			case FALL: 	M.data.mkChar( spr, "hero", "fall");
			
			
			case ATTACK: 		
				var a = spr.play("hero.attack");
				a.loop = false;
				a.onFinish = function() changeState(STAND);
				attack(false);
			
			case AIR_ATTACK:	
				var a = spr.play("hero.airAttack");
				a.loop = false;
				if (dy > 0) dy -= 0.1;
				hasAirAttacked = true;
				a.onFinish = function() changeState(FALL);
				attack(true);
		}
		stateLife = 0;
		state = s;
		//trace("changeState");
	}
	
	public override function enterLevel(l:Level)
	{
		spr.putInFront(l.structure);
	}
	
	public override function onLand()
	{
		changeState(STAND);
		hasAirAttacked = false;
	}
	
	public override function onFall()
	{
		//if( state != AIR_ATTACK )
		//	changeState(FALL);
	}
	
	static var attackcells = 
	[ 
		{x:0, y:-1 },
		{x:0, y:0 },
		{x:0, y:1 },
		
		{x:1, y:-1 },
		{x:1, y:0 },
		{x:1, y:1 },
		
		{x:2, y:-1 },
		{x:2, y:0 },
		{x:2, y:1 },
	];
	
	static var airAttackcells = 
	[ 
		{x:0, y:-2 },
		{x:0, y:-1 },
		{x:0, y:0 },
		{x:0, y:1 },
		{x:0, y:2 },
		
		{x:1, y:-2 },
		{x:1, y:-1 },
		{x:1, y:0 },
		{x:1, y:1 },
		{x:1, y:2 },
		
		{x:2, y:-2 },
		{x:2, y:-1 },
		{x:2, y:0 },
		{x:2, y:1 },
		{x:2, y:2 },
	];
	
	
	public function attack(isAir)
	{
		var nb = 0;
		for(c in isAir?airAttackcells:attackcells)
		{
			var m = dx > 0 ? 1 : -1;
			
			var ls = l.get( cx + c.x*m, cy + c.y*m );
			if(ls!=null)
			for ( e in ls )
			{
				if ( e.type == ET_PEON )
				{
					var p :Peon = cast e;
					var ok = p.slice();
					if (ok)
					{
						nb++;
						souls++;
					}
				}
			}
		}
		
		if ( nb > 0)
		{
			M.sndHead.random().play();
		}
		else
		{
			M.sndMiss.play();
		}
	}
	
	public function updateState()
	{
		switch(state)
		{
			default:
			case JUMP:
				if ( mt.deepnight.Key.isDown(K.UP) && stateLife <= 6 )
					dy -= 0.015;
				
				if ( dy > 0)
					changeState(FALL);
			case AIR_ATTACK:
				
		}
	}
	
	public override function update()
	{
		if ( pause ) 
		{
			super.update();
			return;
		}
		
		if (prevT == null)
		{
			prevT = flash.Lib.getTimer();
		}
		else
		{
			var g = flash.Lib.getTimer();
			var dt = g - prevT; 
			timer += dt;
			prevT = g;
			
			if ( timer / 1000.0 > 112.0 )
			{
				M.terminate();
				return;
			}
		}
		
		var mdx = 0.05;
		
		var control = 0.6;
		if ( falling ||hasJumped)
			control *= 0.6;
		
		dx *= 0.9;
			
		var mdy = -1.0;
		if ( mt.deepnight.Key.isDown(K.UP) 
		&& !hasJumped
		&& !falling
		&& 	( ((state == STAND || state == WALK) &&	stateLife>15)
			|| (state==FALL&&stateLife<=5))
		)
		{
			dy -= 0.12;
			hasJumped = true;
			changeState(JUMP);
		}
		else
			hasJumped  = false;
			
		var baseX = 0.006;
		var doLR = true;
		
		if ( state == ATTACK)
			doLR = false;
			
		if (doLR)
		{
			if ( mt.deepnight.Key.isDown(K.LEFT))
			{
				dx -= baseX * control;
				if ( dx < -mdx * control) dx = -mdx * 0.2 + 0.8 * dx;
				if ( state == STAND && dx < -0.03)
					changeState(WALK);
			}
			
			if ( mt.deepnight.Key.isDown(K.RIGHT))
			{
				dx += baseX * control;
				if ( dx > mdx * control) dx = mdx * 0.2 + 0.8 * dx;
				if ( state == STAND && dx > 0.03)
					changeState(WALK);
			}
		}
		
		if ( mt.deepnight.Key.isDown(K.CONTROL) || mt.deepnight.Key.isDown(K.SPACE))
		{
			if ( (state == JUMP || state == FALL) && !hasAirAttacked )
				changeState(AIR_ATTACK);
			else if( state == STAND ||state  == WALK )
				changeState(ATTACK);
		}
		
		{
			var r = endRatio();
			r = r * r;
			if ( r > 1)
				r = 1;
				
			var ir = 1.0 - r;
			
			var gb = new flash.filters.GlowFilter();
			gb.color = 0x00000;
			gb.blurX = 14*r;
			gb.blurY = 14*r;
			gb.alpha = 0.3 + r * 0.7;
			
			spr.filters = [gb];
		}
		
		updateState();
		
		super.update();
		
		if(state!=null)
		switch(state)
		{
			default:
			case WALK:
				if ( Math.abs(dx) < 1e-2 && Math.abs(dy) < 1e-2 )
					changeState(STAND);	
		}
		stateLife++;
	}
	
}