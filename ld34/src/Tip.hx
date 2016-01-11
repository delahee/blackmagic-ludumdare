
class Tip {
	var app(get, null) : App; 			function get_app() return App.me;
	var d(get, null) : D; 				function get_d() return App.me.d;
	
	public function new( p : h2d.Sprite ) {
		parent = p;
	}
	
	var tipTimer = 0.0;
	var tipSp : h2d.Sprite;
	var tipDecay = false;
	var tipSpawn = 0.0;
	var parent : h2d.Sprite;
	
	public function untip(label) {
		var lbl : h2d.Text = cast  tipSp.findByName("label");
		if ( lbl.text == label ){
			tipDecay = true;
			tipSpawn = 1.0;
		}
	}
	
	public  function tip( x, y, label) {
		tipTimer = 1.0;
		tipDecay = false;
		
		if ( tipSp == null ) {
			tipSp = new h2d.Sprite(parent);
			var bg = new h2d.Graphics(tipSp);
			bg.name = "bg";
			
			var t = new h2d.Text( d.arial, tipSp );
			t.name = "label";
			t.color = h3d.Vector.fromColor(0xFF050505);
			t.filter = true;
			t.maxWidth = 80;
		}
		tipSp.x = x;
		tipSp.y = y;
		var bg : h2d.Graphics = cast tipSp.findByName("bg");
		bg.clear();
		
		var lbl : h2d.Text = cast tipSp.findByName("label");
		lbl.text = label;
		
		var margin = 2;
		var b : h2d.col.Bounds = lbl.getBounds(tipSp);
		bg.lineStyle(1.0, 0xFF000000);
		bg.beginFill(0xffdc94);
		bg.drawRect( b.x-margin, b.y-margin, b.width+margin*2, b.height+margin*2 );
		bg.endFill();
		
		mt.heaps.fx.Lib.setAlpha( tipSp, 0.0 );
		
		if( y < mt.Metrics.h() - tipSp.height)
			tipSp.y += tipSp.height;
			
		if( x >= mt.Metrics.w() - tipSp.width)
			tipSp.x -= tipSp.width;
			
		tipSpawn = 0.2;
		
		tipSp.x = Std.int(x);
		tipSp.y = Std.int(y);
	}

}