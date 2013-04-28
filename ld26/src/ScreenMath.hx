import volute.t.Vec2;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

class ScreenMath extends ScreenGame{
	var lnr : Liner;
	var a : Aster;
	public function new() {
		super();
		
		lnr = new Liner();
		lnr.compile();
	}
	
	
	public override  function init(){
		super.init();
		
		var l = new L();
		var a = null;
		l.addAster( a=new Aster() ).translate( 400, 400);
		for ( ast in l.asters){
			ast.enableTouch();
			ast.a = Math.PI;
		}
		
		G.me.setLevel( l );
		enableTouch();
	}
	
	public function enableTouch() {
		touchable = true;
		addEventListener( TouchEvent.TOUCH , function mup(e:TouchEvent)
		{
			trace("screenMath");
			var touch: Touch = e.touches[0];
			if(touch!=null){
				if(touch.phase == TouchPhase.ENDED)
				{
					var loc = touch.getLocation(this);
					lnr.clear();
						lnr.addPoint( loc.x, loc.y , 0xFF0000, 5.0);
						
						var v = new Vec2(loc.x, loc.y);
						var ei = a.getInterestingEdge( v );
						
						//lnr.addPoint( pnt.x, pnt.y , 0x00FF00, 10.0);
						var p0 = a.getInEdgeRotGlb(ei);
						var p1 = a.getOutEdgeRotGlb(ei);
						
						lnr.addPoint( p0.x, p0.y , 0xFF0000, 10.0);
						lnr.addPoint( p1.x, p1.y , 0x00FF00, 10.0);
						//var pnt = a.intersectAster( new Vec2(loc.x, loc.y) );
						//lnr.addPoint( pnt.x,pnt.y , 0x00FF00, 10.0);
						
					lnr.compile();
				}
		}});
	}
	
}