package h2d;

using mt.heaps.Api2D;

/**
	 * a tiny thingy button thing
	 * @param	msg
**/
class Button extends Sprite {
	
	public var bg(default,set) : Sprite;
	public var interact : h2d.Interactive;
	public var label : Text;
	public var greyed(default, set) : Bool = false;
	
	public var tile:Null<h2d.Tile>;
	public var hover(default,set):Null<h2d.Tile>;
	
	
	/**
	 * a tiny button thing
	 * @param	msg
	 * @param	font
	 * @param	onClick
	 * @param	tile
	 * @param	p
	 */
	public function new( msg:String, font:Font, onClick : Void->Void, ?tile:Tile, ?p:Sprite ) {
		super(p);
		
		interact = new Interactive( tile==null ? 0 : tile.width, tile ==null ? 0 : tile.height, this );
		interact.onClick = function(_) onClick();
		interact.name = "interact";
			
		label = new h2d.Text(font,this);
		label.name="label";
		label.text = msg;
		label.textColor = 0xffFFFFFF; 
		label.dropShadow = { dx: pxi(1.0), dy: pxi(1.0), color:0, alpha:1 };
		
		if( tile != null ) {
			var bmp = new Bitmap( this.tile = tile, this);
			label.toFront();
			interact.toFront();
			bg = bmp;
		}
	}
	
	public override function set_width(w:Float):Float {
		scaleX = w / bg.width;
		return w;
	}
	
	public override function set_height(h:Float):Float {
		scaleY = h / bg.height;
		return h;
	}
	
	function getBmp() :h2d.Bitmap{
		return cast bg;
	}
	
	inline function set_hover(t:h2d.Tile) {
		interact.onOver = function(_) {
			if ( Std.is( bg , h2d.Bitmap)) {
				getBmp().tile = t;
			}
		};
		
		interact.onOut = function(_) {
			if ( Std.is( bg , h2d.Bitmap)) {
				getBmp().tile = tile;
			}
		};
		return hover=t;
	}
	
	inline function pxi( v ) 			return mt.Metrics.vpx2px(v);
	public inline function click()		interact.onClick( new hxd.Event(ESimulated) );
	
	public function makeBg(col:Int,?alpha:Float=1.0){
		var outlineSize = Math.round(mt.Metrics.vpx2px( 1.0 ));
		var margin = Math.round(mt.Metrics.vpx2px( 4.0 ));
		var gfx = new h2d.Graphics();
		gfx.lineStyle(outlineSize);
		gfx.beginFill(col,alpha);
		gfx.drawRect( 0,0,Math.round(label.textWidth+outlineSize+margin*2), Math.round(label.textHeight+outlineSize+margin*2)); 
		gfx.endFill();
		bg = gfx;
		return this;
	}
	
	function set_bg(s : Sprite){
		if( s==null){
			bg=null;
			return bg;
		}
		if( bg!=null)
			bg.dispose();
		s.remove();
		addChild(s);
		bg=s;
		bg.toBack();
		interact.toFront();
		label.x = Math.round(bg.x + bg.width * 0.5 - label.textWidth * 0.5);
		label.y = Math.round(bg.y + bg.height * 0.5  - label.textHeight * 0.5);
		interact.x = bg.x;
		interact.y = bg.y;
		interact.width = Math.round(bg.width);
		interact.height = Math.round(bg.height);
		greyed=greyed;
		return s;
	}
	
	function set_greyed(v:Bool) {
		if ( v ) {
			var m = new h3d.Matrix();
			m.colorSaturation( 0.0 );
			bg.setColorMatrix( m);
			interact.visible = false;
		}
		else {
			interact.visible = true;
			bg.setColorMatrix( null );
		}
		greyed=v;
		return greyed;
	}
	
}