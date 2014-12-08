
class ColumnGraphics extends h2d.Graphics {
	var app(get, null) : App; 			function get_app() return App.me;
	var d(get, null) : D; 				function get_d() return App.me.d;
	var g(get, null) : G; 				function get_g() return App.me.g;
	var c(get, null) : CenterScreen;	function get_c() return CenterScreen.me;
	
	public var selected(default, null):Bool;
	public var idx:Int;
	
	var rect:h3d.Vector;
	var hovered = false;
	
	public function new(p,r,idx) {
		super(p);
		rect = r.clone();
		this.idx = idx;
		blendMode = Add;
		selected = false;
		hovered = false;
	}
	
	public function setDehovered() {
		hovered = false;
		if ( selected ) 
			return;
		clear();
	}
	
	var ofs = C.CH * 0.5 + 50;
	public function setHovered() {
		if ( selected ) return;
		hovered = true;
		clear(); 
		lineStyle(4.0, isLocked() ? 0xFF0000: 0x00FF00,0.5);
		drawRect( rect.x+2, rect.y+2 + ofs, rect.z-2, rect.w -2 - ofs);
		alpha = 1.0;
	}
	
	public function setSelected() {
		selected = true;
		clear(); 
		lineStyle(4.0, isLocked() ? 0xFF0000: 0xFF00FF,0.5);
		drawRect( rect.x+2,rect.y+2 + ofs,rect.z-2,rect.w-2  - ofs);
		alpha = 1.0;
	}
	
	public function setDeselected() {
		clear();
		selected = false;
	}
	
	public function char() {
		return c.char[idx];
	}
	
	public function isLocked() {
		return c.char[idx] ==null ? false : c.char[idx].isLocked();
	}
	
	public function update(tmod:Float) {
		if ( !selected ) {
			if ( hovered )
				setHovered();
		}
		else 
			setSelected();
	}
	
}
