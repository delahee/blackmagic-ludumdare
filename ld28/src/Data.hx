import flash.display.Bitmap;
import flash.display.BitmapData;
import haxe.ds.StringMap;
import haxe.ds.IntMap;
import haxe.Json;
import pix.Store;
import haxe.xml.Parser;
import volute.Lib;

using volute.Ex;


@:bitmap("tiles_bg.png")
class Bg extends flash.display.BitmapData
{
    
}

@:file("tiled/tiles_map.json")
class Tiles extends flash.utils.ByteArray
{
	
}

@:file("sprites.xml")
class ShoeboxXml extends flash.utils.ByteArray
{
	
}

@:bitmap("sprites.png")
class Sprites extends BitmapData
{
	
}

typedef XMLSlice =
{
	xml:haxe.xml.Fast,
	coord: { 	x : Int, y: Int, h: Int,  w : Int},
	nb: { x:Int, y:Int },
}

typedef XMLState =
{
	xml:haxe.xml.Fast,
	id:String,
	slices:Array<XMLSlice>,
}

typedef XMLSprite =
{
	xml:haxe.xml.Fast,
	id:String,
	states:Array<XMLState>,
}

class Data
{
	public var lib		: mt.deepnight.SpriteLibBitmap;
	
	public function new() {
		tiles = Json.parse( new Tiles().toString() );
		bg = new Bg( 0, 0, false );
		
		//makeShoebox();
		
		lib = mt.deepnight.SpriteLibBitmap.importShoeBox("asset/sprites.xml");
		lib.setDefaultCenter(0.5, 0.5);
	}
	
	var tiles : Dynamic = null;
	var bg:  BitmapData;
	
	public inline function getTiles() : Dynamic
		return tiles;
	
	public function getBg() 
		return bg;
		
	/*
	var sb_sheet:BitmapData;
	var sb_store:Store;
	var sprites : StringMap<XMLSprite>;
	var shoebox : haxe.xml.Fast;
	
	public function makeShoebox()
	{
		var shoeBmp = null;
		shoeBmp = new Sprites(0, 0, false);
		
		var shoeboxStr = new ShoeboxXml().toString();
		shoebox = new haxe.xml.Fast( Parser.parse( shoeboxStr) );
		
		var i = Std.parseInt;
		var cs = new pix.Store(shoeBmp);
		sb_sheet = shoeBmp;
		sb_store = cs;
		var lastPrefix = null;
		var frameCount = 0;
		var cfr = 0;
		var bfr = 0;
		for ( subs in shoebox.node.TextureAtlas.nodes.SubTexture ) {
			var id = subs.att.name.split('.png')[0];
			
			var spl = subs.att.name.split('_');
			var suffix = spl.last();
			spl.pop();
			var prefix = spl.join('_');
			
			if ( lastPrefix != null && lastPrefix != prefix) {
				var anm = lastPrefix + ".idle";
				trace(anm + " " + cfr);
				cs.addAnim( anm, Lib.rangeMinMax(0, cfr) );
			}
			
			if( !cs.index.exists( id )){
				cs.addIndex(id);
				cfr = 0;
				bfr = frameCount;
			}
				
			var x, y, w , h;
			cs.addFrame(x = i(subs.att.x), y = i(subs.att.y), w = i(subs.att.width), h = i(subs.att.height));
			var slice = null;
			sprites.set(id, { xml:null, id:id, states:[ { xml:null, id:'idle', slices:slice=[{
				xml:null,
				coord: { 	x : x, y: y,
							h: h,  w : w},
				nb: { x:1, y:1},
			}] } ] } );
			
			
			lastPrefix = prefix;
			frameCount++;
			cfr++;
		}
	}*/
}