import T;
using Math;
class CenterScreen extends S{
	public function new(s) 	{
		super(s);
		
		new h2d.Bitmap( h2d.Tile.fromColor(0x7F000000,scene.width.round(),scene.height.round()), scene );
	}
	
	public override function update(tmod) {
		super.update(tmod);
	}
}