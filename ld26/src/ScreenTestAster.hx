import flash.ui.Keyboard;
import volute.Dice;
import volute.Lib;

import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

import mt.deepnight.Key;

import volute.Types;
import Aster;

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
		level.addAster( new Aster(100) ).translate( 400, 400 );
		level.addAster( new Aster(true, 100) ).translate( 800, 200 );
		level.addAster( new Aster(true, 75) ).translate( 900, 400 );
		var a = level.addAster( new Aster(false, 75) ).translate( 1100, 400 );
		
		a.cine = 
		{
			script: {
				var l = new List();
					l.push( { line:"Hi what r u duin here", side:SPlayer } );
					l.push( { line:"coding a game, havin a bowl", side:SOther } );
					l.push( { line:"kinda fell of my spaceship, can u hint a  way to nearest spaceport ?", side:SPlayer } );
					l.push( { line:"oh wait i have a gameplay for that, its simple you can take two token, pretend they are fighting each other", side:SOther } );
					l.push( { line:"bla bla bla bla bla bla", side:SOther } );
					l.push( { line:"bla bla bla bla bla bla", side:SOther } );
					l.push( { line:"anyway when the fruit reaches, the cat you have on the head", side:SOther } );
					l.push( { line:"you obviously feel entertained...", side:SOther } );
					l.push( { line:"*this guy is crazy* ok i have to go, i have a lot to do and a port to find", side:SOther } );
					l.push( { line:"ok bye ! ", side:SOther } );
				l;
			},
			proc:function() {
				player.mute = true;
			},
		};
		
		for ( ast in level.asters){
			ast.enableTouch();
			ast.a = Dice.rollF( 0 , Math.PI);
		}
		
		addChild( lnr.img );
		
		player =  new Player();
		addChild( player.mc);
		player.setAsterAngle( level.asters[0], - Math.PI / 2);
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
		
		//player.updateKey();
		player.update();
		
		
	}
	
}