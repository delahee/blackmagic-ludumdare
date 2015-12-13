
class FxLayer {
	var addPartBatch:h2d.SpriteBatch; 
	var addPartPool : Array<mt.deepnight.HParticle>=[];
	
	var blendPartBatch:h2d.SpriteBatch;
	var blendPartPool : Array<mt.deepnight.HParticle> = [];
	
	public var visible(default, set):Bool;
	
	static var GUID = 0;
	var id = 0;
	public function new(parent:h2d.Sprite, ?masterTile:h2d.Tile) {
		var tile = masterTile;
		var p = parent.localToGlobal();
		
		addPartBatch = new h2d.SpriteBatch( tile, parent);
		addPartBatch.blendMode = Add;
		addPartBatch.x = -p.x;
		addPartBatch.y = -p.y;
		addPartPool = mt.deepnight.HParticle.initPool( addPartBatch, 200);
		
		blendPartBatch = new h2d.SpriteBatch( tile, parent);
		blendPartBatch.x = -p.x;
		blendPartBatch.y = -p.y;
		blendPartPool = mt.deepnight.HParticle.initPool( blendPartBatch, 200);
		
		id = GUID++;
		
		addPartBatch.name = "addPartBatch #" + id;
		blendPartBatch.name = "blendPartBatch #" + id;
	}
	
	public inline function toBack() {
		addPartBatch.toBack();
		blendPartBatch.toBack();
	}
	
	public inline function toFront() {
		addPartBatch.toFront();
		blendPartBatch.toFront();
	}
	
	public inline function set_visible(v) {
		addPartBatch.visible = v;
		blendPartBatch.visible = v;
		return v;
	}
	public function update() {
		for ( p in addPartPool) 	p.update(true);
		for ( p in blendPartPool)	p.update(true);
	}
	
	public inline function partAdd(tile,x:Float,y:Float): mt.deepnight.HParticle{
		var p = mt.deepnight.HParticle.allocFromPool( addPartPool, tile,x,y);
		return p;
	}
	
	public inline function partBlend(tile,x:Float,y:Float): mt.deepnight.HParticle{
		var p = mt.deepnight.HParticle.allocFromPool( blendPartPool, tile,x,y);
		return p;
	}
	
	public function kill() {
		addPartPool = null;
		blendPartPool = null;
		addPartBatch.dispose();
		blendPartBatch.dispose();
	}
	
}