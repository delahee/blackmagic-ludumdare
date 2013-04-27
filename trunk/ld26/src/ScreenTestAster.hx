import volute.Dice;
import volute.Lib;
class ScreenTestAster extends ScreenGame
{
	var lnr : Liner;
	
	public function new() 
	{
		super();
		lnr = new Liner();
		lnr.compile();
	}
	
	override public function init() {
		super.init();
		
		var l = new L();
		
		l.addAster( new Aster().rand() ).translate( 150,150);
		l.addAster( new Aster().rand() ).translate( 400,400);
		
		G.me.setLevel( l );
		addChild( G.me );
		addChild( lnr.img );
		
		lnr.clear();
		
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
			lnr.addPoint( v.v.x + da.img.x,v.v.y + da.img.y, 0xA19F05);
		
			
		for ( re in da.edges ) lnr.addLine( 	da.img.x - dpx + re.inv.x, 		da.img.y - dpy + re.inv.y, 
												da.img.x - dpx + re.outv.x, 	da.img.y - dpy + re.outv.y ,0xFF0000);
												
		for ( re in da.rotEdges ) lnr.addLine( 	da.img.x - dpx + re.inv.x, 		da.img.y - dpy + re.inv.y, 
												da.img.x - dpx + re.outv.x, 	da.img.y - dpy + re.outv.y, 0x00FF00);
		
		//origin
		lnr.addPoint( da.img.x, da.img.y , 0x0);
		
		//tl
		lnr.addPoint( da.img.x - da.img.pivotX, da.img.y - da.img.pivotY, 0xCDCDCD);
												
		lnr.compile();
	}
	
	public override function update() {
		super.update();
		//for ( a in G.me.l.asters ) a.img.rotation = M.timer.curT * 0.1;
	}
	
}