import flash.ui.Keyboard;
import starling.display.Image;
import volute.Dice;
import volute.Lib;
import volute.t.Vec2;

import mt.deepnight.Key;

import volute.Types;
import Aster;
import Data;

using volute.Ex;

class ScreenTestAster extends Screen
{
	var lnr : Liner;
	var player : Player;
	var sf : Starfield;
	
	var img : Image;
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
		
		sf = new Starfield( this, Lib.w()*5, Lib.h(),1.0,400);
		var a = new Aster(50);
		level.addAster( a ).translate( 150, 150 );
		var b = level.addAster( new Aster(100) ).translate( 400, 400 );
		//level.addAster( new Aster( 100) ).translate( 800, 200 );
		level.addAster( new Aster( true, 75) ).translate( 900, 400 );
		var a = level.addAster( new Aster(false, 75) ).translate( 1100, 400 );
		
		//makeElvis(b);
		
		for ( ast in level.asters)
			ast.a = Dice.rollF( 0 , Math.PI);
		
		addChild( lnr.img );
		
		player =  new Player();
		addChild( player.mc);
		player.setAsterAngle( level.asters[0], - Math.PI / 2);
		
		bg.toBack();
		sf.root.toBack();
		for ( a in level.asters)
			a.img.toFront();
		player.mc.toFront();
		
		img = new Image(Data.me.getTex("planetes", 'idle', 0));
		img.readjustSize();
		img.pivotX = img.width * 0.5;
		img.pivotY = img.height * 0.5;
		//addChild( img );
	}
	
	public function makeElvis(b:Aster) 
	{
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
		/*
		var f = Data.me.getFramesRectTex('props', 'idle');
		var d = new starling.display.Image( f[Std.random(f.length - 1)]);
		d.readjustSize();
		
		addChild( d );
		
		d.x = 50;
		d.y = 500;
		*/
	}
	
	
	override public function kill() {
		var b = super.kill();
		if ( b ){
			sf.dispose();
		}
		return b;
	}
		
	var spin = 0;
	var enableDDraw = false;
	public override function update() {
		super.update();
		//player.updateKey();
		player.update();
		sf.update();
		for ( a in level.asters) 
			a.update();
	}
	
}