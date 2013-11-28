import flash.display.BitmapData;
import mt.deepnight.SpriteLib;
import haxe.xml.Fast;
using volute.com.Ex;

class BmpLd extends BitmapData
{
	
}

class BmpTiles extends BitmapData
{
	
}

class BmpChar extends BitmapData
{
	
}

class BmpSky 	extends BitmapData{}
class BmpLight	extends BitmapData { }
class BmpBg01	extends BitmapData { }
class BmpBg02	extends BitmapData{}


typedef XMLSlice =
{
	xml:haxe.xml.Fast,
	coord: { 	x : Int, y: Int,
				h: Int,  w : Int},
	nb: { x:Int, y:Int },
	hitbox :
	{
		x:Int,y:Int,w:Int,h:Int
	}
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

class Data implements haxe.Public
{
	var ld : BmpLd;
	var tiles : BmpTiles;
	var tileLib : mt.deepnight.SpriteLib;
	
	var xml : haxe.xml.Fast;
	var gd : haxe.xml.Fast;
	var tileDef : haxe.xml.Fast;
	
	var wallIndex : IntHash<{col:Int,idx:Int,xml:Fast}>;
	var charIndex : IntHash<{col:Int,cat:Int,?named:String,xml:Fast}>;
	var propIndex : IntHash<{col:Int,sprite:String,xml:Fast}>;
	
	var charStore : pix.Store;
	
	var charData : Hash<XMLSprite>;
	var pnjPhrases : Array<Ods.PnjData>;
	

	public function new()
	{
		ld = new BmpLd(0,0,false);
		tiles = new BmpTiles(0, 0, false);
		xml = new haxe.xml.Fast( haxe.xml.Parser.parse( haxe.Resource.getString( "asset")) );
		
		gd = xml.node.gd;
		tileDef = xml.node.tileDef;
		
		tileLib = new SpriteLib(tiles);
		tileLib.setUnit(16);
		tileLib.sliceUnit( "wall", 0, 0, 5, 50);
		
		var bmp = new BitmapData(16, 16);
		tileLib.drawIntoBitmap(bmp, 0, 0, "wall");
		
		charData = new Hash();
		wallIndex = new IntHash();
		for ( u in xml.node.tileMap.node.wall.elements)
		{
			var c = Std.parseInt(u.att.col);
			var idx = Std.parseInt(u.att.index);
			wallIndex.set(c,{ col:c,idx: idx, xml:u });
		}
		charIndex = new IntHash();
		for ( u in xml.node.tileMap.node.char.elements)
		{
			var c = Std.parseInt(u.att.col);
			var t;
			charIndex.set( c, t = { col:c, named:u.has.named?u.att.named:null, cat:Std.parseInt(u.att.cat), xml:u } );
			
			if( t.cat >= 10)
				Tools.assert( t.named != null );
		}
		
		propIndex = new IntHash();
		for ( u in xml.node.tileMap.node.prop.elements)
		{
			var c = Std.parseInt(u.att.col);
			propIndex.set( c, { col:c, sprite:u.att.sprite,xml:u} );
		}
		
		{
			charStore = new pix.Store( new BmpChar(0, 0, true));
			
			var el = new pix.Element();
			pix.Element.DEFAULT_STORE = charStore;
			pix.Element.DEFAULT_ALIGN_Y = 1.0;
			
			for ( spr in tileDef.nodes.sprite )
			{
				var sprId;
				charStore.addIndex(sprId = spr.att.id);
				var frameCount = 0;
				var xmlStates = [];
				for(s in spr.nodes.state)
				{
					var stId = s.att.id;
					var slices = [];
					var fr = 0;
					var ofr = frameCount;
					
					for(sl in s.nodes.slice )
					{
						var coo = sl.att.coord.split(',')
						.map( Std.parseInt)
						.array();
						var nb : Array<Null<Int>> = (!sl.has.nb) ? [] : sl.att.nb.split(',')
						.map( Std.parseInt)
						.array();
						
						var s : XMLSlice =
						{
							xml:sl,
							coord: { x:coo[0], y:coo[1], w:coo[2], h:coo[3] },
							nb: { x:nb[0] == null?1 : nb[0],
								y:nb[1] == null?1 : nb[1],
							},
							hitbox:
							{
								var hcoo = sl.att.coord.split(',')
								.map( Std.parseInt)
								.array();
								
								if ( sl.hasNode.hitbox )	{ x:hcoo[0], y:hcoo[1], w:hcoo[2], h:hcoo[3] };
								else						{ x:0, y:0, w:coo[2], h:coo[3]};
							}
						};
						
						fr += s.nb.x * s.nb.y;
						charStore.slice( s.coord.x, s.coord.y, s.coord.w, s.coord.h, s.nb.x, s.nb.y);
						slices.pushBack(s);
						frameCount += s.nb.x * s .nb.y;
					}
					
					var xmlState : XMLState =
					{
						id:stId,
						xml:s,
						slices:slices,
					}
					
					var anm = sprId + "." + stId;
					charStore.addAnim( anm, Tools.rangeMinMax(ofr,frameCount) , s.has.rythm ? Tools.splat( Std.parseInt(s.att.rythm), fr ) : null );
					xmlStates.pushBack(xmlState);
				}
				
				var xmlSprite : XMLSprite =
				{
					xml:spr,
					id:sprId,
					states:xmlStates,
				}
				charData.set( sprId, xmlSprite);
			}
		}
		
		pnjPhrases = Ods.pnj.copy();
	}
	
	public function reset()
	{
		pnjPhrases = Ods.pnj.copy();
	}
	
	public function mkChar( el : ElementEx, sprite:String, state:String )
	{
		var s = sprite + "." + state;
		el.play( s );
	}
}