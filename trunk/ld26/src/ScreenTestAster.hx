import flash.ui.Keyboard;
import volute.Dice;
import volute.Lib;
import volute.t.Vec2;

import mt.deepnight.Key;

import volute.Types;
import Aster;
import Data;

using volute.com.LbdEx;

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
		me = this;
	}

	
	override public function init() {
		super.init();
		
		var a = new Aster(100);
		level.addAster( a ).translate( 150, 150 );
		var b = level.addAster( new Aster(100) ).translate( 400, 400 );
		level.addAster( new Aster( 100) ).translate( 800, 200 );
		level.addAster( new Aster( 75) ).translate( 900, 400 );
		var a = level.addAster( new Aster(false, 75) ).translate( 1100, 400 );
		
		
		b.cine = 
		{
			type:ELVIS,
			sprite: "elvis",
			script: {
				var l = new List();
					l.add( { line:"Hi what r u duin here", side: SPlayer } );
					l.add( { line:"Hi what r u duin here", side: SOther } );
				l;
			},
			proc:function() { player.mute = true; },
			ofsSprite:new Vec2(420,220),
			ofsSpeech:new Vec2(0,0),
		};
		
		for ( ast in level.asters)
			ast.a = Dice.rollF( 0 , Math.PI);
		
		addChild( lnr.img );
		
		player =  new Player();
		addChild( player.mc);
		player.setAsterAngle( level.asters[0], - Math.PI / 2);
	}
	
	
	var spin = 0;
	var enableDDraw = false;
	public override function update() {
		super.update();
		//player.updateKey();
		player.update();
	}
	
}