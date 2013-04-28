import volute.t.Vec2;


class ScreenMath extends ScreenGame{
	var lnr : Liner;
	var as : Aster;
	public function new() {
		super();
		
		lnr = new Liner();
		lnr.compile();
	}
	
	
	public override  function init(){
		super.init();
		
		var l = new L();
		l.addAster( as=new Aster() ).translate( 400, 400);
		for ( ast in l.asters){
			ast.a = Math.PI;
		}
		
		var p = [0xFF0000, 0x00FF00, 0x0000FF, 0xFFFFFF];
		lnr.clear();
		for (i in 0...as.rotVtx.length)
		{
			var v = as.getVtxRotGlb(i);
			lnr.addPoint(v.x, v.y, p[i], 5);
		}
		lnr.compile();
		
		
		G.me.setLevel( l );
		addChild( lnr.img );
	}
	
}