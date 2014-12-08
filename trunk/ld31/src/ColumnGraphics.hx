
class ColumnGraphics extends h2d.Graphics {
	public var selected(default, null):Bool;
	public var idx:Int;
	
	var rect:h3d.Vector;
	var hovered = false;
	
	public function new(p,r,idx) {
		super(p);
		rect = r.clone();
		this.idx = idx;
		blendMode = Add;
	}
	
	public function setDehovered() {
		hovered = false;
	}
	
	var ofs = C.CH * 0.5 + 50;
	public function setHovered() {
		if ( selected ) return;
		hovered = true;
		clear(); 
		
		lineStyle(4.0, 0x00FF00,0.5);
		drawRect( rect.x+2, rect.y+2 + ofs, rect.z-2, rect.w -2 - ofs);
		alpha = 1.0;
	}
	
	public function setSelected() {
		hovered = true;
		selected = true;
		clear(); 
		lineStyle(4.0, 0xFF00FF,0.5);
		drawRect( rect.x+2,rect.y+2 + ofs,rect.z-2,rect.w-2  - ofs);
		alpha = 1.0;
	}
	
	public function setDeselected() {
		clear();
		selected = false;
	}
	
	public function update(tmod:Float) {
		if(!selected && !hovered)
			alpha -= tmod * 0.1;
	}
}
