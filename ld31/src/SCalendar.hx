import T;

class PendulElem extends h2d.Bitmap {
	public var elem:Elem;
	public function new (t, p,e) {
		super(t, p);
		elem = e;
	}
}

class SCalendar extends S {
	var pendulum : PendulElem;
	var side : Dir;
	var elemSpin : Int;
	var spin:Float;
	var interact:h2d.Interactive;
	public function new(s) {
		elemSpin += getElemOffset();
		super(s);
		spin = C.FPS * (getPeriod() - 0.1);
		side = Center;
		makeDecor();
	}
	
	public function makeDecor() {}
	public function getElemOffset() {
		return 0;
	}
	
	public function elemOf(spin) {
		return ((spin) & 1) == 0 ? Light : Dark;
	}
	
	public function getPeriod() {
		return 10.0;
	}
	
	public function newPendulum() {
		var elem = elemOf(elemSpin);
		var h = new PendulElem( d.decor.getTile("bgElement"), root, elem );
		h.tile.setCenterRatio( 0.5, 0.5);
		var tileName = {
			switch( elem ) {
				case Light: "sun";
				case Dark:	"moon";
				case Fire:	"fire";
				case Water:	"water";
				case Earth:	"earth";
				case None:	"pixel_transparent";
			}
		}
		var t = d.char.h_get( tileName, h);
		t.setCenter( 0.5, 0.5);
		
		pendulum = h;
		elemSpin++;
	}
	
	public function onOver(_) {
	}
	
	public function onOut(_) {
	}
	
	public function moveCadrants() {
		newPendulum();
		g.cadrans[side] = pendulum.elem;
		for ( cs in c.char )
			if( cs != null)
				cs.refreshGaugeTile();
				
		D.sfx.element_change().play();
	}
	
	public override function update(tmod:Float) {
		super.update(tmod);
		spin += tmod;
		
		if ( spin >= C.FPS * getPeriod()) {
			moveCadrants();
			spin = 0.0;
		}
	}
}




