package mt.heaps.fx;


class Lib {
	public static function setAlphaMin( h : h2d.Sprite , c : Float) {
		h.traverse( function (sp) {
			if ( Std.is(sp, h2d.Drawable)) {
				var d : h2d.Drawable = cast sp;
				d.alpha = Math.min( d.alpha, c);
			}
		});
	}
	
	public static function setAlpha( h : h2d.Sprite , c : Float) {
		h.traverse( function (sp) {
			if ( Std.is(sp, h2d.Drawable)) {
				var d : h2d.Drawable = cast sp;
				d.alpha = c;
			}
		});
	}
	
	public static function setAlphaMax( h : h2d.Sprite , c : Float) {
		h.traverse( function (sp) {
			if ( Std.is(sp, h2d.Drawable)) {
				var d : h2d.Drawable = cast sp;
				d.alpha = Math.max( d.alpha, c);
			}
		});
	}
	
	public static function traverseDrawables( h : h2d.Sprite , proc : h2d.Drawable -> Void ) {
		h.traverse( function (sp) {
			if ( Std.is(sp, h2d.Drawable)) 
				proc( Std.instance( sp, h2d.Drawable ));
		});
	}
}