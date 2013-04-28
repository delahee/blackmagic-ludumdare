import volute.t.Vec2;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

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
			//ast.enableTouch();
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
		enableTouch();
	}
	
	public function enableTouch() {
		touchable = true;
		addEventListener( TouchEvent.TOUCH , function mup(e:TouchEvent)
		{
			//trace("screenMath");
			var touch: Touch = e.touches[0];
			if(touch!=null){
				if(touch.phase == TouchPhase.ENDED)
				{
					var loc = touch.getLocation(this);
					lnr.clear();
						trace("center:"+as.getGlbCenter());
						trace("hit:"+loc);
						lnr.addPoint( loc.x, loc.y , 0x00FFFF, 5.0);
						
						var v = new Vec2(loc.x, loc.y);
						var ei = as.getInterestingEdge( v );
						
						//lnr.addPoint( loc.x, loc.y , 0x00FFff, 10.0);
						
						
						if ( ei >= 0){
							var p0 = as.getInEdgeRotGlb(ei);
							var p1 = as.getOutEdgeRotGlb(ei);
							
							lnr.addPoint( p0.x, p0.y , 0xFF0000, 10.0);
							lnr.addPoint( p1.x, p1.y , 0x00FF00, 10.0);
						}
						
						//var pnt = a.intersectAster( new Vec2(loc.x, loc.y) );
						//lnr.addPoint( pnt.x,pnt.y , 0x00FF00, 10.0);
						
					lnr.compile();
				}
		}});
	}
	
}