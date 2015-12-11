package mt.heaps;

class Number extends h2d.Text {
	public var headingSign = false;
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
		text = ( headingSign && nb>0) ? "+"+Std.string( nb ) : Std.string( nb );
		
		return nb;
	}
	
}