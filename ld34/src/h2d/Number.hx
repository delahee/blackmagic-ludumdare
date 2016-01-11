package h2d;

class Number extends h2d.Text {
	public var headingSign = false;
	public var trailingPercent = false;
	public var headingMul = false;
	public function new(fnt,?p) {
		super(fnt, p);
	}
	
	public var nb(get, set): Float;
	
	function get_nb() : Float {
		if ( text == "" ) return -0.0001;
		
		return Std.parseInt( text );
	}
	
	function set_nb( nb : Float ) {
		var oldNb = get_nb();
		if ( oldNb == nb ) return nb;
		
		var nb = Std.int( nb );
		
		var txt;
		if ( headingSign && nb >= 0) 
			txt = "+" + Std.string( nb );
		else 
			txt = Std.string( nb );
			
		if ( trailingPercent ) txt += "%";
		if ( headingMul ) txt = "x"+txt;
		
		text = txt;
		return nb;
	}
	
}