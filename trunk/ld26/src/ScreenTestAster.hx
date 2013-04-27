import volute.Dice;
import volute.Lib;

import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

class ScreenTestAster extends ScreenGame
{
	var lnr : Liner;
	var player : Player;
	public function new() 
	{
		super();
		lnr = new Liner();
		lnr.compile();
		
		player =  new Player();
	}
	
	public function debugDraw()
	{
		lnr.clear();
		var l = G.me.l;
		var da = l.asters[1];
		
		var tlx = da.img.x - da.img.pivotX;
		var tly = da.img.y - da.img.pivotY;
		
		var brx = tlx + da.img.width;
		var bry = tly + da.img.height;
		
		var dpx = da.img.pivotX;
		var dpy = da.img.pivotY;
		
		lnr.addLine( 	tlx,tly, brx,tly, 0xF53D54 );
		lnr.addLine( 	tlx,tly, tlx,bry, 0xF53D54);
		
		for ( v in da.vtx ) 
			lnr.addPoint( v.v.x -dpx + da.img.x , v.v.y - dpy + da.img.y , 0xA19F05);
			
		for ( v in da.rotVtx ) 
			lnr.addPoint( v.x -dpx + da.img.x , v.y - dpy + da.img.y , 0xFFFFFF);
			
		//for ( re in da.rotEdges ) lnr.addLine( 	da.img.x -dpx + re.inv.x, 	da.img.y -dpy + re.inv.y, 
		//										da.img.x -dpx + re.outv.x, 	da.img.y -dpy + re.outv.y, 0x00FF00);
		
		//origin
		lnr.addPoint( da.img.x, da.img.y , 0x0);
		
		//tl
		lnr.addPoint( da.img.x - da.img.pivotX, da.img.y - da.img.pivotY, 0xCDCDCD);
												
		lnr.compile();
	}
	
	override public function init() {
		super.init();
		
		var l = new L();
		
		l.addAster( new Aster() ).translate( 150,150);
		l.addAster( new Aster() ).translate( 400, 400);
		
		for ( ast in l.asters)
			ast.enableTouch();
		
		G.me.setLevel( l );
		addChild( G.me );
		addChild( lnr.img );
		
		enableTouch();
		
	}
	
	public function enableTouch() {
		addEventListener( TouchEvent.TOUCH , function mup(e:TouchEvent)
		{
			var touch: Touch = e.touches[0];
			if(touch!=null){
				if(touch.phase == TouchPhase.ENDED)
				{
					var loc = touch.getLocation(this);
					trace("mup on " + loc );
					
					lnr.clear();
						lnr.addPoint( loc.x, loc.y , 0xFF0000, 10.0);
						player.pos.x = loc.x;
						player.pos.y = loc.y;
						var p =Player.putOnAster( G.me.l.asters[1],player.pos.clone() );
						lnr.addPoint( p.outPos.x, p.outPos.y , 0x00FF00,10.0);
					lnr.compile();
				}
		}});
	}
	
	var spin = 0;
	var enableDDraw = true;
	public override function update() {
		super.update();
		for ( a in G.me.l.asters ) a.a = M.timer.curT * 0.1;
		
		if( enableDDraw && spin++%10 == 0 )
			debugDraw();
	}
	
}