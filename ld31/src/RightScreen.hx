import T;

using Math;

class RightScreen extends S{
	public function new(s) 	{
		super(s);
		new h2d.Bitmap( h2d.Tile.fromColor(0x7fFF0000,scene.width.round(),scene.height.round()), scene );
	}
	
	public override function update(tmod) {
		super.update(tmod);
	}
}