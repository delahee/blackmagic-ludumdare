import volute.Dice;
import volute.Lib;

import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

class ScreenTestAster extends Screen
{
	var lnr : Liner;
	var player : Player;
	
	public var me : ScreenTestAster;
	public function new() 
	{
		super();
		lnr = new Liner();
		lnr.compile();
		
		player =  new Player();
		me = this;
	}

	
	override public function init() {
		super.init();
		
		level.addAster( new Aster() ).translate( 150,150);
		level.addAster( new Aster() ).translate( 400, 400);
		
		for ( ast in level.asters){
			ast.enableTouch();
			ast.a = Dice.rollF( 0 , Math.PI);
		}
		
		addChild( lnr.img );
	}
	
	
	public function enableTouch() {
		addEventListener( TouchEvent.TOUCH , function (e:TouchEvent)
		{
			var touch: Touch = e.touches[0];
			if(touch!=null){
				if(touch.phase == TouchPhase.ENDED)
				{
					var loc = touch.getLocation(this);
					trace("mup on " + loc );
					
					lnr.clear();
						lnr.addPoint( loc.x, loc.y , 0xFF0000, 10.0);
						//player.pos.x = loc.x;
						//player.pos.y = loc.y;
						//var p =Player.putOnAster( G.me.l.asters[1],player.pos.clone() );
						//lnr.addPoint( p.outPos.x, p.outPos.y , 0x00FF00,10.0);
					lnr.compile();
				}
		}});
	}
	
	
	var spin = 0;
	var enableDDraw = false;
	public override function update() {
		super.update();
		
	}
	
}